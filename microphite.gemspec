# -*- encoding: utf-8 -*-
# Copyright (c) 2013 BZ Technology Services, LLC
# Released under the MIT License (http://opensource.org/licenses/MIT)

$:.unshift File.expand_path('../lib', __FILE__)
require 'microphite/version'

Gem::Specification.new do |gem|
  gem.name = 'microphite'
  gem.version = Microphite::VERSION
  gem.authors = %w(Bob Ziuchkovski)
  gem.email = %w(bob@bz-technology.com)
  gem.summary = 'A blazing fast, thread-safe graphite client'
  gem.description = 'A blazing fast, thread-safe graphite client'
  gem.homepage = 'https://github.com/ziuchkovski/microphite'

  #gem.add_runtime_dependency 'timers', '>= 1.1.0'
  gem.add_development_dependency 'rspec'

  gem.files = `git ls-files`.split("\n")
  gem.test_files = `git ls-files -- spec/*`.split("\n")
  gem.require_paths = %w(lib)
end
