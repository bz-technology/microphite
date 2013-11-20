require 'rake/testtask'
require 'rspec/core/rake_task'

namespace :test do
  RSpec::Core::RakeTask.new do |t|
    t.name = 'spec'
    t.pattern = 'spec**/*_sped.rb'
  end
end
