# when debugging!
require 'pry'

# application code
require_relative 'foræ'
require_relative 'fora'
require_relative 'mora'

#
class ForaMora
  def self.run
    @fora = Fora.select_target
    raise 'Fora not prepared!' unless @fora.present?
    @mora = Mora.new(fora: @fora)
    @mora.simulate!

    puts 'Done! Cleaning up…'
    sleep 4
    # cleanup!
    @fora.teardown
  end
end
