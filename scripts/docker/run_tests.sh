#!/bin/sh

set -e

# Matrix of Ruby and Rails versions
RUBY_VERSIONS="3.1.4 3.2.2"
RAILS_VERSIONS="6.1 7.0 7.1"

# Iterate over Ruby versions
for RUBY_VERSION in $RUBY_VERSIONS; do
  . "$ASDF_DIR/asdf.sh"
  asdf local ruby $RUBY_VERSION

  # Iterate over Rails versions
  for RAILS_VERSION in $RAILS_VERSIONS; do
    # Set the Rails version environment variable
    export TEST_RAILS_VERSION=$RAILS_VERSION
    echo "Testing with Ruby $RUBY_VERSION and Rails $RAILS_VERSION"

    # Install gems
    bundle install

    # Run tests
    bundle exec rspec
  done
done

bundle exec standardrb --generate-todo
