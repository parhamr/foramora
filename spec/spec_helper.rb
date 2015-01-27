# encoding: UTF-8
# coding: UTF-8
# -*- coding: UTF-8 -*-

require 'active_support'
require 'active_support/time'
require 'active_support/core_ext'

RSpec.configure do |config|
  require 'simplecov'

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
  end

  SimpleCov.start do
    add_filter '/spec/'
 
    add_group 'Application', '../lib/'
    add_group 'Configuration', '../config/'
  end

  # find all of these paths
  Dir[
    # attempts cross platform support
    File.join('.', 'lib', '**', '*.rb'),
    File.join('.', 'spec', 'support', '**', '*.rb')
  ].sort.each do |file|
    # build the require statement
    dirname = File.dirname(file)
    basename = File.basename(file, '.rb')
    require_statement = File.join(dirname, basename)
    # puts "requiring #{require_statement.inspect}"
    require require_statement
  end
end

