#!/usr/bin/ruby

# general bootstrap and utilities
require 'rubygems'
require 'bundler/setup'
Bundler.setup(:default)

require './lib/fora_mora'

ForaMora.run
