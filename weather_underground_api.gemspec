# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'weather_underground_api/version'

Gem::Specification.new do |spec|
  spec.name          = "weather_underground_api"
  spec.version       = WeatherUndergroundApi::VERSION
  spec.authors       = ["thestelz"]
  spec.email         = ["stelzera24@gmail.com"]
  spec.summary       = %q{A simple api to weather underground's api.}
  spec.description   = %q{A simple class object to call weather underground's api with your developer key.}
  spec.homepage      = "https://simpleweatherapp.herokuapp.com/"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '~> 1.6'
  spec.add_development_dependency 'rake', '~> 10.0', '>= 10.0.0'
  spec.add_development_dependency 'activesupport', '~> 4.2', '>= 4.2.3'
end
