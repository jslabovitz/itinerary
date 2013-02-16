#encoding: utf-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'itinerary/version'

Gem::Specification.new do |gem|
  gem.name          = 'itinerary'
  gem.version       = Itinerary::VERSION
  gem.authors       = 'John Labovitz'
  gem.email         = 'johnl@johnlabovitz.com'
  gem.summary       = %q{Keep track of travel itineraries}
  gem.description   = %q{A Ruby gem to keep track of travel itineraries.}
  gem.homepage      = 'https://github.com/jslabovitz/itinerary.git'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency 'bundler'
  gem.add_development_dependency 'rake'

  gem.add_runtime_dependency 'builder'
  gem.add_runtime_dependency 'faraday'
  gem.add_runtime_dependency 'faraday_middleware'
  gem.add_runtime_dependency 'geocoder'
  gem.add_runtime_dependency 'hashstruct'
  gem.add_runtime_dependency 'haversine'
  gem.add_runtime_dependency 'nokogiri'
  gem.add_runtime_dependency 'rack-cache'
end