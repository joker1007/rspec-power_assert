require "rspec/power_assert/version"
require "rspec/core"
require "power_assert"

module RSpec
  module PowerAssert
    def is_asserted_by(&blk)
      result = nil
      msg = nil
      ::PowerAssert.start(blk, assertion_method: __method__) do |tp|
        result = tp.yield
        msg = tp.message_proc.call
      end

      if result
        RSpec::Matchers.last_matcher = DummyAssertionMatcher.new(msg)

        if RSpec::Matchers.respond_to?(:last_should=)
          RSpec::Matchers.last_should = "" # for RSpec 2
        else
          RSpec::Matchers.last_expectation_handler = DummyExpectationHandler # for RSpec 3
        end
      else
        raise RSpec::Expectations::ExpectationNotMetError, msg
      end
    end

    # for generating description
    class DummyExpectationHandler
      def self.verb
        ""
      end
    end

    # for generating description
    class DummyAssertionMatcher
      def initialize(msg)
        @msg = msg
      end

      def description
        "\n#{@msg}"
      end
    end
  end
end

RSpec.configure do |config|
  config.include RSpec::PowerAssert
end
