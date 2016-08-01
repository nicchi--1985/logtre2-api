require 'test_helper'

class TradeAnalyzerTest < ActiveSupport::TestCase
  setup do
    @trade = trades(:one)
    logger.info(@trade)
  end

  test 'sample' do
    assert @trade.trade_datetime == DateTime.new(2016,7,1,10,0,0)
  end
end