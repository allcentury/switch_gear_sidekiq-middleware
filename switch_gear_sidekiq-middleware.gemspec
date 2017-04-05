# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'switch_gear_sidekiq/middleware'

Gem::Specification.new do |spec|
  spec.name          = "switch_gear_sidekiq-middleware"
  spec.version       = SwitchGearSidekiq::Middleware::VERSION
  spec.authors       = ["Anthony Ross"]
  spec.email         = ["anthony.s.ross@gmail.com"]

  spec.summary       = %q{A Sidekiq middleware that implements the circuit breaker pattern}
  spec.description   = %q{This gem allows for users of Sidekiq in a distributed system to use a common circuit breaker that can be used across any number of Sidekiq servers"}
  spec.homepage      = "https://github.com/allcentury/switch_gear_sidekiq-middlware"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'sidekiq'
  spec.add_dependency 'switch_gear', '~> 0.2.0'
  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "simplecov", "~> 0.13"
  spec.add_development_dependency "yard", "~> 0.9"
end
