# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'phase/version'

Gem::Specification.new do |spec|
  spec.name          = "phase"
  spec.version       = Phase::VERSION
  spec.authors       = ["Piers Mainwaring", "Orca Health, Inc."]
  spec.email         = ["piers@impossibly.org"]
  spec.summary       = "A simple way to manage cloud instances within a multi-subnet network, like an AWS VPC."
  spec.description   = ""
  spec.homepage      = "https://github.com/piersadrian/phase"
  spec.license       = "MIT"

  spec.required_ruby_version = '~> 2.0'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'commander',      '~> 4.2'
  spec.add_runtime_dependency 'terminal-table', '~> 1.4'
  spec.add_runtime_dependency 'progressbar',    '~> 0.21'
  spec.add_runtime_dependency 'activesupport',  '~> 4'
  spec.add_runtime_dependency 'fog',            '~> 1.23'
  spec.add_runtime_dependency 'capistrano',     '~> 3.2'
  spec.add_runtime_dependency 'colorize',       '~> 0.7'
  spec.add_runtime_dependency 'dotenv',         '~> 0.11'

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake',    '~> 10.1'
  spec.add_development_dependency 'rspec',   '~> 3.1'
  spec.add_development_dependency 'pry',     '~> 0.10'
end
