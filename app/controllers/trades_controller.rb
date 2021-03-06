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
    trades = current_user.trades.where(["trade_type = ?", TradeTypeEnum::SELL])
    summary = Trade.summarize(trades=trades)
    render :json => summary
  end

  def productSummary
    term_days = 180
    ref_start = current_user.trades
                            .where(["broker_no = ? and product_no = ? and trade_type = ?", 
                                  Trade.broker_nos[params[:broker].to_sym], 
                                  Trade.product_nos[params[:product].to_sym], 
                                  TradeTypeEnum::SELL])
                            .order("trade_datetime DESC")
                            .first
                            .trade_datetime.to_date
    term_end = ref_start - (term_days * params[:term].to_i)
    term_start = term_end + term_days
    trades = current_user.trades.where(["trade_datetime >= ? and trade_datetime <= ?", term_end, term_start])
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
    logger.debug('response brokers')
    logger.debug(brokers)
    render :json => brokers
  end

  def chart_data
    term_days = 180
    ref_start = current_user.trades
                            .where(["broker_no = ? and product_no = ? and trade_type = ?", 
                                  Trade.broker_nos[params[:broker].to_sym], 
                                  Trade.product_nos[params[:product].to_sym], 
                                  TradeTypeEnum::SELL])
                            .order("trade_datetime DESC")
                            .first
                            .trade_datetime.to_date
    
    term_end = ref_start - (term_days * params[:term].to_i)
    term_start = term_end + term_days
    # select * from trades where broker_no=xx and product_no=yy and trade_type=zz order by trade_datetime desc limit 1;
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
