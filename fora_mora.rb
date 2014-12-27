#!/usr/bin/ruby

# configs
require_relative "config/fora_mora"

# general bootstrap and utilities
require 'rubygems'
require 'active_support'
require 'active_support/time'
require 'active_support/core_ext'
require 'logging'

# application code
#require_relative "lib/foræ"
require_relative "lib/fora"
require_relative "lib/mora"

@fora = Fora.select_application
@mora = Mora.new()

puts "Done! Cleaning up…"
sleep 4
# cleanup!
@fora.teardown
