# Rspec::PowerAssert

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

### spec
```ruby
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
  end
end
```

### output
```
Rspec::PowerAssert
  Array
    #map
      example at ./spec/rspec/power_assert_spec.rb:13 (FAILED - 1)
      example at ./spec/rspec/power_assert_spec.rb:17 (FAILED - 2)
      is_asserted_by { subject.map(&:upcase) == %w(A B C) }
                         |       |             |
                         |       |             true
                         |       ["A", "B", "C"]
                         ["a", "b", "c"]
      should transform array

Failures:

  1) Rspec::PowerAssert Array#map
     Failure/Error: is_asserted_by { subject.map(&:upcase) == array }
               is_asserted_by { subject.map(&:upcase) == array }
                                |       |             |  |
                                |       |             |  [1, 2, 3]
                                |       |             false
                                |       ["A", "B", "C"]
                                ["a", "b", "c"]
     # ./lib/rspec/power_assert.rb:19:in `is_asserted_by'
     # ./spec/rspec/power_assert_spec.rb:14:in `block (4 levels) in <top (required)>'

  2) Rspec::PowerAssert Array#map
     Failure/Error: is_asserted_by { upcased == @array }
               is_asserted_by { upcased == @array }
                                |       |  |
                                |       |  [1, 2, 3]
                                |       false
                                ["A", "B"]
     # ./lib/rspec/power_assert.rb:19:in `is_asserted_by'
     # ./spec/rspec/power_assert_spec.rb:20:in `block (4 levels) in <top (required)>'

Finished in 0.00455 seconds (files took 0.10298 seconds to load)
4 examples, 2 failures

Failed examples:

rspec ./spec/rspec/power_assert_spec.rb:13 # Rspec::PowerAssert Array#map
rspec ./spec/rspec/power_assert_spec.rb:17 # Rspec::PowerAssert Array#map
```

## Contributing

1. Fork it ( https://github.com/joker1007/rspec-power_assert/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
