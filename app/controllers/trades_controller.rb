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
    term_days = 180
    trades = current_user.trades.where(["trade_datetime > ?", Date.today - term_days])
    if params[:broker]
      trades = trades.where(["broker_no=?", Trade.broker_nos[params[:broker].to_sym]])
    end
    if params[:product]
      trades = trades.where(["product_no=?", Trade.product_nos[params[:product].to_sym]])
    end
    summary = Trade.summarize(trades=trades)
    render :json => summary
  end

  def brokers
    trades = current_user.trades.select(:broker_no).distinct
    brokers = trades.map {|trade| {name: trade.broker_no, disp_name: BROKER_NAME[trade.broker_no]}}
    render :json => brokers
  end

  def chart_data
    term_days = 180
    term_end = Date.today - (term_days * params[:term].to_i)
    term_start = term_end + term_days
    trades = current_user.trades
                         .where(["broker_no = ? and product_no = ? and trade_type = ? and trade_datetime >= ? and trade_datetime <= ?", 
                                  Trade.broker_nos[params[:broker].to_sym], 
                                  Trade.product_nos[params[:product].to_sym], 
                                  TradeTypeEnum::SELL, 
                                  term_end,
                                  term_start])
                         .order(:trade_datetime)
    chart_data = ChartDataSerializer.serialize(trades)
    chart_data = chart_data.merge({term_start: term_start, term_end: term_end})
    render :json => chart_data
  end

  def analytics
    term_days = 180
    trades = current_user.trades.where(["trade_datetime > ?", Date.today - term_days])
    analytics = TradeAnalyzer.new(trades).analyze
    render :json => analytics
  end
end
