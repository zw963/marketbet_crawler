require_relative '../config/environment.rb'

symbols = %w(
  nasdaq/arry nasdaq/fldm nyse/beke nasdaq/lizi nasdaq/momo
  nyse/stm  otcmkts/dlaky otcmkts/rycey nasdaq/niu nyse/lu
  nyse/umc nyse/nclh nasdaq/cron nyse/pltr nasdaq/ttcf
  nasdaq/kopn nasdaq/afrm nasdaq/cree nasdaq/dada nasdaq/fami
  nyse/dao nasdaq/ino nasdaq/tour nyse/tme nyse/ai
  nasdaq/eh otcmkts/wcagy
)

symbols.each do |e|
  exchange, stock = e.split('/')
  exchange = Exchange.find_or_create(name: exchange)

  if not Stock.find(name: stock, exchange: exchange)
    Stock.create(name: stock, exchange: exchange)
  end
end
