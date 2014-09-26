# -*- encoding: utf-8 -*-
# Copyright (c) 2013 BZ Technology Services, LLC
# Released under the MIT License (http://opensource.org/licenses/MIT)

$:.unshift File.expand_path('../lib', __FILE__)
require 'microphite/version'

Gem::Specification.new do |gem|
  gem.name = 'microphite'
  gem.version = Microphite::VERSION
  gem.authors = %w(BZ Technology Services, LLC)
  gem.email = %w(support@bz-technology.com)
  gem.summary = 'A tiny and fast, asynchronous graphite client'
  gem.description = 'A tiny and fast, asynchronous graphite client'
  gem.homepage = 'https://github.com/bz-technology/microphite'

  gem.add_development_dependency 'rake', '~> 10.0'
  gem.add_development_dependency 'rspec', '~> 2.14.1'
  gem.add_development_dependency 'coveralls', '~> 0.7'

  gem.files = `git ls-files`.split("\n")
  gem.test_files = `git ls-files -- spec/*`.split("\n")
  gem.require_paths = %w(lib)
end
