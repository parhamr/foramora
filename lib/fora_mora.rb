# encoding: UTF-8
# coding: UTF-8
# -*- coding: UTF-8 -*-

# when debugging!
require 'pry'

# load the first order of application code
# FIXME: cross-platform support?
Dir[
  './lib/*.rb',
].sort.each do |file|
  # build the require statement
  dirname = File.dirname(file)
  basename = File.basename(file, '.rb')
  require_statement = File.join(dirname, basename)
  # puts "requiring #{require_statement.inspect}"
  require require_statement
end

#
class ForaMora
  def self.run
    # TODO: this class might be the appropriate location for the Selenium @driver object
    # (because it does not need repeated initialization in tests)
    @fora = Fora.select_target
    raise 'Fora not prepared!' unless @fora.present?
    @mora = Mora.new(fora: @fora)
    @mora.simulate!

    puts 'Done! Cleaning up…'
    sleep 4
  ensure
    # cleanup!
    @fora.teardown
  end
end
