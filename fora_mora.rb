#!/usr/bin/ruby

# general bootstrap and utilities
require 'rubygems'
require 'bundler/setup'
Bundler.setup(:default)

# attempts cross platform support
path = File.join('.', 'lib', 'fora_mora')
# build the require statement
dirname = File.dirname(path)
basename = File.basename(path, '.rb')
require_statement = File.join(dirname, basename)

require require_statement

ForaMora.run
