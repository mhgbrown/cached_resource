#!/bin/sh

set -e

export BUNDLE_SILENCE_ROOT_WARNING=1
export BUNDLE_IGNORE_MESSAGES=1

. "$ASDF_DIR/asdf.sh"
SPEC_RESULTS="coverage/spec_results"
mkdir -p "$SPEC_RESULTS"

# Matrix of Ruby and Rails versions
RUBY_VERSIONS=$(asdf list ruby)
RAILS_VERSIONS="6.1 7.0 7.1"

# Maximum number of concurrent processes
MAX_PARALLEL=3
CURRENT_PARALLEL=0

run_rspec() {
  local ruby_version="$1"
  local rails_version="$2"

  echo "********* Testing with Ruby $ruby_version and Rails $rails_version *********"

  # Install gems
  TEST_RAILS_VERSION="$rails_version" bundle install --quiet --no-cache

  # Run tests
  TEST_RAILS_VERSION="$rails_version" bundle exec rspec \
    --format failures \
    --format html --out "$SPEC_RESULTS/$ruby_version-$rails_version.index.html"
}

# Iterate over Ruby versions
for RUBY_VERSION in $RUBY_VERSIONS; do
  asdf reshim ruby $RUBY_VERSION
  asdf shell ruby $RUBY_VERSION

  # Iterate over Rails versions
  for RAILS_VERSION in $RAILS_VERSIONS; do
    # Parallelize with arbitrary limit to prevent crashing
    while [ $CURRENT_PARALLEL -ge $MAX_PARALLEL ]; do
      sleep 1
      CURRENT_PARALLEL=$(jobs | wc -l)
    done

    (run_rspec "$RUBY_VERSION" "$RAILS_VERSION") & CURRENT_PARALLEL=$((CURRENT_PARALLEL + 1))
  done

  wait

  CURRENT_PARALLEL=0
done

echo "********* Running Linter *********"
bundle exec standardrb \
  --format html --out "coverage/linter-results.index.html" \
  --format offenses

echo "********* DONE *********"
