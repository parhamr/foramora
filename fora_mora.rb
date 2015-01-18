#!/usr/bin/ruby

# configs
require_relative "config/fora_mora"

# general bootstrap and utilities
require 'rubygems'
require 'bundler/setup'
Bundler.setup(:default)

require 'active_support'
require 'active_support/time'
require 'active_support/core_ext'
require 'logging'

# application code
require_relative "lib/foræ"
require_relative "lib/fora"
require_relative "lib/mora"

@fora = Fora.select_application
raise 'Fora not prepared!' unless @fora.present?
#@fora.test
@mora = Mora.new(fora: @fora)
@mora.browse!
#@more.create_thread!

puts "Done! Cleaning up…"
sleep 4
# cleanup!
@fora.teardown
