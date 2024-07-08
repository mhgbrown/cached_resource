require 'timeout'

RSpec::Matchers.define :eventually do |expected_matcher|
  supports_block_expectations

  chain :within do |timeout_duration|
    @timeout_duration = timeout_duration
  end

  match do |actual|
    begin
      Timeout.timeout(@timeout_duration || 5) do
        until expected_matcher.matches?(actual.call)
          sleep 0.5
        end
        true
      end
    rescue Timeout::Error
      false
    end
  end

  description do
    description_text = "eventually #{expected_matcher.description}"
    description_text += " within #{@timeout_duration} seconds" if @timeout_duration
    description_text
  end

  failure_message do |actual|
    "expected #{actual.call} to #{description}"
  end

  failure_message_when_negated do |actual|
    "expected #{actual.call} not to #{description}"
  end
end
