#!/usr/bin/env rake
# encoding: UTF-8
# coding: UTF-8
# -*- coding: UTF-8 -*-

require 'rake'

desc 'Run RSpec with code coverage'
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['spec'].execute
end
