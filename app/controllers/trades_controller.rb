class TradesController < ApplicationController
  BROKER_NAME = {
    BrokerEnum::SBI => "SBI証券",
    BrokerEnum::GMO => "GMO証券",
    BrokerEnum::RAKUTEN => "楽天証券",
  }
  def index
    trades = Trade.all()
    render :json => trades
  end
  def summary
    term_days = 360
    trades = current_user.trades.where(["trade_datetime > ? and gain_loss_amount != 0", Date.today - term_days])
    summary = Trade.summarize(trades=trades)
    render :json => summary
  end
  def brokers
    trades = current_user.trades.select(:broker_no).distinct
    brokers = trades.map {|trade| {id: trade.broker_no, disp_name: BROKER_NAME[trade.broker_no]}}
    render :json => brokers
  end
end
