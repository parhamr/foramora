#!/usr/bin/ruby
# encoding: UTF-8
# coding: UTF-8
# -*- coding: UTF-8 -*-

# general bootstrap and utilities
require 'rubygems'
require 'bundler/setup'
Bundler.setup(:default)

# attempts cross platform support
path = File.join('.', 'lib', 'fora_mora')
require File.join(File.dirname(path), File.basename(path, '.rb'))

ForaMora.bootstrap
ForaMora.run
