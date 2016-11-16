class ChartDataController < ApplicationController
    skip_before_action :authenticate_request!
    def product_chart
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

    def nikkei
        start_date = Date.strptime(params[:start], "%Y-%m-%d")
        end_date = Date.strptime(params[:end], "%Y-%m-%d")
        data = Nikkei.where(["date <= ? and date >= ?", start_date, end_date]).order(:date)
        chart_data = []
        data.each do |n|
            chart_data.push({x: n.date, y: n.last_price})
        end
        render :json => {data: chart_data, time_unit: "month", term_start: start_date, term_end: end_date}
    end
end
