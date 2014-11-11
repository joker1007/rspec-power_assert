# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rspec/power_assert/version'

Gem::Specification.new do |spec|
  spec.name          = "rspec-power_assert"
  spec.version       = Rspec::PowerAssert::VERSION
  spec.authors       = ["joker1007"]
  spec.email         = ["kakyoin.hierophant@gmail.com"]
  spec.summary       = %q{Power Assert for RSpec.}
  spec.description   = %q{Power Assert for RSpec..}
  spec.homepage      = "https://github.com/joker1007/rspec-power_assert"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "power_assert", "~> 0.2.0"
  spec.add_runtime_dependency "rspec", ">= 2.14"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
