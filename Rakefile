# encoding: UTF-8
# coding: UTF-8
# -*- coding: UTF-8 -*-

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

# find all of these paths
Dir[
  # attempts cross platform support
  File.join('.', 'lib', 'tasks', '*.rb')
].sort.each do |file|
  # build the require statement
  dirname = File.dirname(file)
  basename = File.basename(file, '.rb')
  require_statement = File.join(dirname, basename)
  # puts "requiring #{require_statement.inspect}"
  require require_statement
end
