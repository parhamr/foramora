# encoding: UTF-8
# coding: UTF-8
# -*- coding: UTF-8 -*-

require 'rubygems'
require 'bundler/setup'
Bundler.setup(:default)

require 'active_support'
require 'active_support/time'
require 'active_support/core_ext'

RSpec.configure do |config|
  # disable SimpleCov when running through Guard
  if ENV['COVERAGE']
    # NOTE: this must happen before application code is required
    require 'simplecov'
    require 'launchy'
    SimpleCov.start do
      add_filter '/spec/'
      add_filter '/lib/tasks/'
      add_group 'Application', '../lib/'
      add_group 'Configuration', '../config/'
    end

    config.after(:suite) do
      # Open the newly generated coverage report
      Launchy.open('file://' + File.join(__dir__, '..', 'coverage', 'index.html'))
    end
  end

  config.add_setting :selenium_webdriver, default: :firefox

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
  end

  config.before(:each, selenium: false) do
    allow(Selenium::WebDriver).to receive(:for).and_return(Selenium::FakeDriver.new)
    allow_any_instance_of(Selenium::FakeDriver).to receive(:find_element).and_return(nil)
    allow_any_instance_of(Selenium::FakeDriver).to receive(:find_elements).and_return([])
    allow_any_instance_of(Selenium::FakeDriver).to receive(:get).and_return(true)
  end

  # find all of these paths
  Dir[
    # attempts cross platform support
    File.join('.', 'lib', '*.rb'),
    File.join('.', 'lib', 'forae', '*.rb'),
    File.join('.', 'lib', 'fora_mora', '*.rb'),
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
