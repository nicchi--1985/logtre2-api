class ProductsController < ApplicationController
    def index
        term_days = 180
        trades = current_user.trades.where(["broker_no = ? and trade_type = ? and trade_datetime > ?", 
                                                params[:broker], 
                                                TradeTypeEnum::SELL, 
                                                Date.today - term_days])
        @products = Trade.summarize_by_product(trades)
        render :json => @products
    end
end
