require_relative 'ally/account'
require_relative 'ally/market'

class Trading
  def self.start
    new.start
  end

  def start
    puts "We started!"
    account = Ally::Account.new
    market = Ally::Market.new

    puts account.all
    puts account.find('61942085')
    puts market.clock
    puts account.balances
  end
end