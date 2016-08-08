require 'spec_helper'

RSpec::PowerAssert.example_assertion_alias :assert
RSpec::PowerAssert.example_group_assertion_alias :assert

describe Rspec::PowerAssert do
  describe Array do
    describe "#map" do
      let(:array) { [1, 2, 3] }
      subject { %w(a b c) }

      before do
        @array = [1, 2, 3]
      end

      it do
        is_asserted_by { subject.map(&:upcase) == array }
      end

      it do
        assert { subject.map(&:upcase) == array }
      end

      it do
        is_asserted_by {
          subject.map(&:upcase) == array
        }
      end

      it do
        is_asserted_by { subject.map(&:upcase) == %w(A B C) }
      end

      it do
        is_asserted_by {
          subject.map(&:upcase) == %w(A B C)
        }
      end

      it do
        upcased = subject.map(&:upcase)
        upcased.pop
        is_asserted_by { upcased == @array }
      end

      it "should transform array" do
        is_expected.to eq %w(a b c)
        is_asserted_by { subject.map(&:upcase) == %w(A B C) }
      end

      it "should transform array (failed)" do
        is_asserted_by { subject.map(&:upcase) == %w(A B) }
      end

      it_is_asserted_by { subject.map(&:upcase) == %w(A B C) }

      assert { subject.map(&:upcase) == %w(A B C) }

      it_is_asserted_by { subject.map(&:upcase) == %w(A B) }

      assert { subject.map(&:upcase) == %w(A B) }

      it_is_asserted_by do
        subject.map(&:upcase) == %w(A B C)
      end

      it_is_asserted_by "succ each element" do
        subject.map(&:succ) == ["b", "c", "e"] + @array
      end

      context "When use aggregate_failures" do
        before do
          unless respond_to?(:aggregate_failures)
            pending_message = "This test can run only on RSpec 3.3+"

            if respond_to?(:skip)
              # for RSpec 3
              skip pending_message
            else
              # for RSpec 2
              pending pending_message
            end
          end
        end

        it "should be called expect with 3 times" do
          aggregate_failures do
            expect(subject.map(&:upcase)).to eq %w(a b c)
            expect(subject.map(&:upcase)).to eq %w(A B C)
            expect(subject.map(&:upcase)).to eq %w(A B C D)
          end
        end

        it "should be called is_asserted_by with 3 times" do
          aggregate_failures do
            is_asserted_by { subject.map(&:upcase) == %w(a b c) }
            is_asserted_by { subject.map(&:upcase) == %w(A B C) }
            is_asserted_by { subject.map(&:upcase) == %w(A B C D) }
          end
        end
      end
    end
  end

  describe Object do
    before do
      PowerAssert.configure do |c|
        c._trace_alias_method = true
      end
    end

    after do
      PowerAssert.configure do |c|
        c._trace_alias_method = false
      end
    end

    let(:object) {
      Class.new {
        def foo
          :foo
        end

        alias alias_of_iseq foo
        alias alias_of_cfunc to_s
      }
    }

    subject { object.new }

    it do
      is_asserted_by { subject.alias_of_iseq == :bar }
    end
  end
end
