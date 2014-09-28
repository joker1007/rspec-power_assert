require "rspec/power_assert/version"
require "rspec/core"
require "power_assert"

module PowerAssert
  class << self
    def rspec_start(assertion_proc, assertion_method: nil)
      yield RSpecContext.new(assertion_proc, assertion_method)
    end
  end

  class RSpecContext < Context
    # hack for context changing
    def do_yield
      @trace.enable do
        @base_caller_length = caller_locations.length + 2
        yield
      end
    end
  end
  private_constant :RSpecContext
end

module RSpec
  module PowerAssert
    def is_asserted_by(&blk)
      result, msg = ::PowerAssert.start(blk, assertion_method: __method__) do |tp|
        [tp.yield, tp.message_proc.call]
      end

      handle_result_and_message(result, msg)
    end

    private

    def evaluate_example(bmethod_name, &blk)
      # hack for context changing
      pr = -> { self.instance_exec(&blk) }

      result, msg = ::PowerAssert.rspec_start(pr, assertion_method: bmethod_name) do |tp|
        [tp.yield, tp.message_proc.call]
      end

      handle_result_and_message(result, msg)
    end

    def handle_result_and_message(result, msg)
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

  module PowerAssertExtensions
    def it_is_asserted_by(description = nil, &blk)
      file, lineno = blk.source_location
      cmd = description ? "it(description)" : "specify"
      eval %{#{cmd} do evaluate_example("#{__method__}", &blk) end}, binding, file, lineno
    end
  end

  module ThenAssertion
    def Then(description = nil, &blk)
      file, lineno = blk.source_location
      cmd = description ? "it(description)" : "specify"
      eval %{#{cmd} do evaluate_example("#{__method__}", &blk) end}, binding, file, lineno
    end
  end
end

RSpec.configure do |config|
  config.extend RSpec::PowerAssertExtensions
  config.include RSpec::PowerAssert
end
