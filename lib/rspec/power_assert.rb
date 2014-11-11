require "rspec/power_assert/version"
require "rspec/core"
require "power_assert"

module PowerAssert
  class << self
    def rspec_start(assertion_proc, assertion_method: nil, source_binding: TOPLEVEL_BINDING)
      yield RSpecContext.new(assertion_proc, assertion_method, source_binding)
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
    @verbose_successful_report = true

    def self.verbose_successful_report
      !!@verbose_successful_report
    end

    def self.verbose_successful_report=(verbose)
      @verbose_successful_report = verbose
    end

    def self.example_assertion_alias(name)
      alias_method(name.to_sym, :is_asserted_by)
    end

    def self.example_group_assertion_alias(name)
      PowerAssertExtensions.assertion_method_alias(name)
    end

    def is_asserted_by(&blk)
      result, msg = ::PowerAssert.start(blk, assertion_method: __callee__) do |tp|
        [tp.yield, tp.message_proc.call]
      end

      handle_result_and_message(result, msg, __callee__)
    end

    private

    def evaluate_example(method_name, &blk)
      # hack for context changing
      pr = -> { self.instance_exec(&blk) }

      result, msg = ::PowerAssert.rspec_start(pr, assertion_method: method_name) do |tp|
        [tp.yield, tp.message_proc.call]
      end

      handle_result_and_message(result, msg, method_name)
    end

    def handle_result_and_message(result, msg, method_name)
      if result
        RSpec::Matchers.last_matcher = DummyAssertionMatcher.new(msg, method_name.to_s)

        if RSpec::Matchers.respond_to?(:last_should=)
          RSpec::Matchers.last_should = :should # for RSpec 2
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
        "should"
      end
    end
    private_constant :DummyExpectationHandler

    class DummyAssertionMatcher
      INDENT_LEVEL = 12

      def initialize(msg, method_name)
        @msg = msg
        @assertion_method = method_name
      end

      def description
        if @msg =~ /^(\s*)#{@assertion_method}/
          output = @msg.sub(/^(\s*#{@assertion_method})/, "#{display_message}")
          offset = display_message.length - $1.length
        else
          output = @msg.sub(/^(\s*)(\S.*?)$/, "#{display_message} { \\2 }")
          offset = display_message.length + 3 - $1.length
        end

        "#{$/}#{build_message(output, offset)}"
      end

      private

      def build_message(output, offset)
        if RSpec::PowerAssert.verbose_successful_report
          output.each_line.with_index.map do |l, idx|
            next l if idx == 0

            if offset > 1
              " " * offset + l
            else
              l.each_char.drop(offset.abs).join
            end
          end.join
        else
          output.each_line.first
        end
      end

      def display_message
        " " * INDENT_LEVEL + "be asserted by"
      end
    end
    private_constant :DummyAssertionMatcher
  end

  module PowerAssertExtensions
    def self.assertion_method_alias(name)
      alias_method name.to_sym, :it_is_asserted_by
    end

    def it_is_asserted_by(description = nil, &blk)
      file, lineno = blk.source_location
      cmd = description ? "it(description)" : "specify"
      eval %{#{cmd} do evaluate_example("#{__callee__}", &blk) end}, binding, file, lineno
    end
  end
end

RSpec.configure do |config|
  config.extend RSpec::PowerAssertExtensions
  config.include RSpec::PowerAssert
end
