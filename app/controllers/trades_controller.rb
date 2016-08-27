class TradesController < ApplicationController
  BROKER_NAME = {
    "sbi" => "SBI証券",
    "gmo" => "GMO証券",
    "rakuten" => "楽天証券",
  }

  def index
    trades = Trade.all()
    render :json => trades
  end

  def summary
    term_days = 360
    trades = current_user.trades.where(["trade_datetime > ?", Date.today - term_days])
    summary = Trade.summarize(trades=trades)
    render :json => summary
  end

  def brokers
    trades = current_user.trades.select(:broker_no).distinct
    brokers = trades.map {|trade| {name: trade.broker_no, disp_name: BROKER_NAME[trade.broker_no]}}
    render :json => brokers
  end

  def chart_data
    trades = current_user.trades
                         .where(["broker_no = ? and product_no = ? and trade_type = ?", params[:broker], params[:product], TradeTypeEnum::SELL])
                         .order(:trade_datetime)
    chart_data = ChartDataSerializer.serialize(trades)
    render :json => chart_data
  end

  def analytics
    trades = current_user.trades
    analytics = TradeAnalyzer.new(trades).analyze
    render :json => analytics
  end
end
