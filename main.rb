require_relative 'properties'
require_relative 'trading'

class Main
  def self.run
    new.run
  end

  def run
    Trading.start
  end
end

Main.run