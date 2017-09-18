require "rspec/power_assert/version"
require "rspec/core"
require "power_assert"

module PowerAssert
  INTERNAL_LIB_DIRS[RSpec::PowerAssert]  = __dir__
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

      location = blk.source_location.join(":")
      handle_result_and_message(result, msg, __callee__, location)
    end

    private

    def evaluate_example(method_name, &blk)
      # hack for context changing
      pr = -> { self.instance_exec(&blk) }

      result, msg = ::PowerAssert.start(pr, assertion_method: method_name) do |tp|
        [tp.yield, tp.message_proc.call]
      end

      location = blk.source_location.join(":")
      handle_result_and_message(result, msg, method_name, location)
    end

    def handle_result_and_message(result, msg, method_name, location)
      if result
        RSpec::Matchers.last_matcher = DummyAssertionMatcher.new(msg, method_name.to_s)

        if RSpec::Matchers.respond_to?(:last_should=)
          RSpec::Matchers.last_should = :should # for RSpec 2
        else
          RSpec::Matchers.last_expectation_handler = DummyExpectationHandler # for RSpec 3
        end
      else
        ex = RSpec::Expectations::ExpectationNotMetError.new(msg)

        if defined?(RSpec::Support) && RSpec::Support.respond_to?(:notify_failure)
          # for RSpec 3.3+
          RSpec::Support.notify_failure(ex)
        else
          # for RSpec 2, 3.0, 3.1, 3.2
          ex.set_backtrace(location)
          raise ex
        end
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
      file, _lineno = blk.source_location
      backtrace = caller.drop_while {|l| l !~ /#{Regexp.escape(file)}/}
      it description, caller: backtrace do
        evaluate_example(__callee__, &blk)
      end
    end
  end
end

RSpec.configure do |config|
  config.extend RSpec::PowerAssertExtensions
  config.include RSpec::PowerAssert
end
