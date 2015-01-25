require 'active_support'
require 'active_support/time'
require 'active_support/core_ext'
require 'rspec'
require 'rspec/its'
require 'factory_girl'

# find all of these paths
# FIXME: cross-platform support?
Dir[
  './lib/**/*.rb',
  './spec/support/**/*.rb'
].sort.each do |file|
  # build the require statement
  dirname = File.dirname(file)
  basename = File.basename(file, '.rb')
  require_statement = File.join(dirname, basename)
  # puts "requiring #{require_statement.inspect}"
  require require_statement
end
