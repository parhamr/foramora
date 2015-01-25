#!/usr/bin/ruby

# configs
require_relative 'config/fora_mora'

# general bootstrap and utilities
require 'rubygems'
require 'bundler/setup'
Bundler.setup(:default)

# when debugging!
require 'pry'

# application code
require_relative 'lib/foræ'
require_relative 'lib/fora'
require_relative 'lib/mora'

@fora = Fora.select_target
raise 'Fora not prepared!' unless @fora.present?
@mora = Mora.new(fora: @fora)
@mora.simulate!

puts 'Done! Cleaning up…'
sleep 4
# cleanup!
@fora.teardown
