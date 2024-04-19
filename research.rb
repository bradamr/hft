require 'httparty'
require 'pg'
require 'date'

def uri(params = nil)
  "https://api.polygon.io/v1/historic/quotes/#{@symbol}/#{@trade_date}?apiKey=PKLP4XEVXGIF2YR5NOQI#{params}"
end

def load
  puts "Enter SYMBOL name:"
  #@symbol = gets.chomp
  @symbol = 'ENPH'

  puts "Enter Date:"
  #  @trade_date = gets.chomp
  @trade_date = '2019-10-29'

  @con = nil
  begin
    @con = PG.connect :dbname => 'enph_data', :user => 'xwps'
    data = trade_data
    until data['ticks'].nil?
      process_data(data)
      offset = data['ticks'].last['t']
      data   = trade_data(offset)
    end
  rescue PG::Error => e
    puts e.message
  ensure
    @con.close if @con
  end
end

def cash(shares, price)
  shares * price
end

def can_invest(cash_available, share_price)
  (cash_available / share_price) >= 1
end

def investable_share_number(cash_available, price, limit = nil)
  limit = 0.9 if limit.nil? # Only allow 90% of available cash to be invested
  (cash_available * limit) / price
end

def analyze
  begin
    @con = PG.connect :dbname => 'enph_data', :user => 'xwps'


    account_cash    = 20
    shares_owned    = 300
    share_price_avg = 22.22
    start_cash      = cash(shares, share_price_avg)
    puts "Starting price: #{start_cash}"

    @con.exec("select * from prices limit 100").each do |record|
      # Current ticker price
      price = record['price']

      # Check if you own 0 shares, if so -- can you invest?
      if shares_owned == 0 && can_invest(account_cash, price)
        # You own nothing but can invest so.. invest

        investable_shares = investable_share_number(account_cash, price, 0)

        account_cash    -= cash(investable_shares, price)
        shares_owned    = investable_shares
        share_price_avg = price

      elsif price > share_price_avg && !can_invest(account_cash, price)
        # You own shares, you have no investable money so let the stocks increase

      elsif price < share_price_avg
        # Sell all the stocks (at the avg price of all the stocks)
        account_cash += cash(shares, price)
      end
    end

    ending_cash = cash(shares, share_price_avg)
    puts "Ending price: #{cash(shares, share_price_avg)}"
  rescue PG::Error => e
    puts e.message
  ensure
    @con.close if @con
  end

end

def trade_data(offset = nil)
  offset_param      = offset.nil? ? offset : "&offset=#{offset}"
  historic_data_uri = uri(offset_param)
  response          = HTTParty.get(historic_data_uri).body
  JSON.parse(response)
end

def process_data(data)
  data['ticks'].each do |ticker|
    epoch_time = ticker['t']
    price      = ticker['bP']

    @con.exec("INSERT INTO prices (price, trade_time, trade_date) VALUES (#{price}, '#{epoch_time}', '#{@trade_date}')")
  end
end

analyze
