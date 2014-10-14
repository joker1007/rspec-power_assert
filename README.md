# Rspec::PowerAssert
[![Gem Version](https://badge.fury.io/rb/rspec-power_assert.svg)](http://badge.fury.io/rb/rspec-power_assert)

## Support
- RSpec 2.14 or later

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rspec-power_assert'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rspec-power_assert

## Usage

First, add require option to `.rspec`

```
-r power_assert
```

Use `ExampleGroup.it_is_asserted_by` or `ExampleGroup#is_asserted_by`

```ruby
describe Object do
  it_is_asserted_by { a == b }

  it do
    is_asserted_by { a == b }
  end
end
```

## Config

### verbose_successful_report

```ruby
RSpec::PowerAssert.verbose_successful_report = true
```

If it set true, Successful Example reports with `power_assert` outputs.
If it set false, Successful Example reports without `power_assert` outputs.

Default is *true*.

### example_assertion_alias

```ruby
# enable `assert` method in Example block
RSpec::PowerAssert.example_assertion_alias :assert
```

### example_group_assertion_alias

```ruby
# enable `assert` method in ExampleGroup block
RSpec::PowerAssert.example_group_assertion_alias :assert
```

## Sample
### spec sample
```ruby
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

      it_is_asserted_by { subject.map(&:upcase) == %w(A B) }

      it_is_asserted_by do
        subject.map(&:upcase) == %w(A B C)
      end

      it_is_asserted_by "succ each element" do
        subject.map(&:succ) == ["b", "c", "e"] + @array
      end
    end
  end
end
```

### output sample
```
Rspec::PowerAssert
  Array
    #map
      example at ./spec/rspec/power_assert_spec.rb:13 (FAILED - 1)
      example at ./spec/rspec/power_assert_spec.rb:17 (FAILED - 2)
      should
        be asserted by { subject.map(&:upcase) == %w(A B C) }
                         |       |             |
                         |       |             true
                         |       ["A", "B", "C"]
                         ["a", "b", "c"]
      should
        be asserted by { subject.map(&:upcase) == %w(A B C) }
                         |       |             |
                         |       |             true
                         |       ["A", "B", "C"]
                         ["a", "b", "c"]
      example at ./spec/rspec/power_assert_spec.rb:33 (FAILED - 3)
      should transform array
      should transform array (failed) (FAILED - 4)
      should
        be asserted by { subject.map(&:upcase) == %w(A B C) }
                         |       |             |
                         |       |             true
                         |       ["A", "B", "C"]
                         ["a", "b", "c"]
      example at ./spec/rspec/power_assert_spec.rb:50 (FAILED - 5)
      should
        be asserted by { subject.map(&:upcase) == %w(A B C) }
                         |       |             |
                         |       |             true
                         |       ["A", "B", "C"]
                         ["a", "b", "c"]
      succ each element (FAILED - 6)

Failures:

  1) Rspec::PowerAssert Array#map
     Failure/Error: is_asserted_by { subject.map(&:upcase) == array }
               is_asserted_by { subject.map(&:upcase) == array }
                                |       |             |  |
                                |       |             |  [1, 2, 3]
                                |       |             false
                                |       ["A", "B", "C"]
                                ["a", "b", "c"]
     # ./lib/rspec/power_assert.rb:57:in `handle_result_and_message'
     # ./lib/rspec/power_assert.rb:31:in `is_asserted_by'
     # ./spec/rspec/power_assert_spec.rb:14:in `block (4 levels) in <top (required)>'

  2) Rspec::PowerAssert Array#map
     Failure/Error: is_asserted_by {
                 subject.map(&:upcase) == array
                 |       |             |  |
                 |       |             |  [1, 2, 3]
                 |       |             false
                 |       ["A", "B", "C"]
                 ["a", "b", "c"]
     # ./lib/rspec/power_assert.rb:57:in `handle_result_and_message'
     # ./lib/rspec/power_assert.rb:31:in `is_asserted_by'
     # ./spec/rspec/power_assert_spec.rb:18:in `block (4 levels) in <top (required)>'

  3) Rspec::PowerAssert Array#map
     Failure/Error: is_asserted_by { upcased == @array }
               is_asserted_by { upcased == @array }
                                |       |  |
                                |       |  [1, 2, 3]
                                |       false
                                ["A", "B"]
     # ./lib/rspec/power_assert.rb:57:in `handle_result_and_message'
     # ./lib/rspec/power_assert.rb:31:in `is_asserted_by'
     # ./spec/rspec/power_assert_spec.rb:36:in `block (4 levels) in <top (required)>'

  4) Rspec::PowerAssert Array#map should transform array (failed)
     Failure/Error: is_asserted_by { subject.map(&:upcase) == %w(A B) }
               is_asserted_by { subject.map(&:upcase) == %w(A B) }
                                |       |             |
                                |       |             false
                                |       ["A", "B", "C"]
                                ["a", "b", "c"]
     # ./lib/rspec/power_assert.rb:57:in `handle_result_and_message'
     # ./lib/rspec/power_assert.rb:31:in `is_asserted_by'
     # ./spec/rspec/power_assert_spec.rb:45:in `block (4 levels) in <top (required)>'

  5) Rspec::PowerAssert Array#map
     Failure/Error: it_is_asserted_by { subject.map(&:upcase) == %w(A B) }
             it_is_asserted_by { subject.map(&:upcase) == %w(A B) }
                                 |       |             |
                                 |       |             false
                                 |       ["A", "B", "C"]
                                 ["a", "b", "c"]
     # ./lib/rspec/power_assert.rb:57:in `handle_result_and_message'
     # ./lib/rspec/power_assert.rb:44:in `evaluate_example'
     # ./spec/rspec/power_assert_spec.rb:50:in `block in it_is_asserted_by'

  6) Rspec::PowerAssert Array#map succ each element
     Failure/Error: it_is_asserted_by "succ each element" do
               subject.map(&:succ) == ["b", "c", "e"] + @array
               |       |           |                    |
               |       |           |                    [1, 2, 3]
               |       |           false
               |       ["b", "c", "d"]
               ["a", "b", "c"]
     # ./lib/rspec/power_assert.rb:57:in `handle_result_and_message'
     # ./lib/rspec/power_assert.rb:44:in `evaluate_example'
     # ./spec/rspec/power_assert_spec.rb:56:in `block in it_is_asserted_by'

Finished in 0.01725 seconds (files took 0.12235 seconds to load)
11 examples, 6 failures

Failed examples:

rspec ./spec/rspec/power_assert_spec.rb:13 # Rspec::PowerAssert Array#map
rspec ./spec/rspec/power_assert_spec.rb:17 # Rspec::PowerAssert Array#map
rspec ./spec/rspec/power_assert_spec.rb:33 # Rspec::PowerAssert Array#map
rspec ./spec/rspec/power_assert_spec.rb:44 # Rspec::PowerAssert Array#map should transform array (failed)
rspec ./spec/rspec/power_assert_spec.rb:50 # Rspec::PowerAssert Array#map
rspec ./spec/rspec/power_assert_spec.rb:56 # Rspec::PowerAssert Array#map succ each element
```

## Contributing

1. Fork it ( https://github.com/joker1007/rspec-power_assert/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
