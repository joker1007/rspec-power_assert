require 'spec_helper'

RSpec.configure do |config|
  config.extend RSpec::ThenAssertion
end

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
        upcased = subject.map(&:upcase)
        upcased.pop
        is_asserted_by { upcased == @array }
      end

      it do
        is_expected.to eq %w(a b c)
        is_asserted_by { subject.map(&:upcase) == %w(A B C) }
      end

      it "should transform array" do
        is_expected.to eq %w(a b c)
        is_asserted_by { subject.map(&:upcase) == %w(A B C) }
      end

      it_is_asserted_by { subject.map(&:upcase) == %w(A B C) }

      it_is_asserted_by do
        subject.map(&:upcase) == %w(A B C)
      end

      it_is_asserted_by "succ each element" do
        subject.map(&:succ) == ["b", "c", "e"] + @array
      end

      Then { subject.map(&:upcase) == %w(A B C) }
    end
  end
end
