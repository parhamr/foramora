#!/usr/bin/ruby

require_relative "config/fora_mora"

require 'active_support'
require 'active_support/time'
require 'active_support/core_ext'

require_relative "lib/fora"
require_relative "lib/mora"

require 'highline/import'
require 'optparse'

puts "Available forae: #{Fora.forae.collect{|f| f['domain']}.to_sentence}"

@mora = Mora.new()

