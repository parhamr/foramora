require 'active_support'
require 'active_support/time'
require 'active_support/core_ext'

# find all of these paths
Dir[
  # attempts cross platform support
  File.join('.', 'lib', '**', '*.rb'),
  File.join('.', 'spec', 'support', '**', '*.rb')
].sort.each do |file|
  # build the require statement
  dirname = File.dirname(file)
  basename = File.basename(file, '.rb')
  require_statement = File.join(dirname, basename)
  # puts "requiring #{require_statement.inspect}"
  require require_statement
end

RSpec.configure do |config|
  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect
  end
end
