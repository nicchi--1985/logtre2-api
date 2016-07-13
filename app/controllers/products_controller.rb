class ProductsController < ApplicationController
    def index
        trades = current_user.trades.where(["broker_no = ? and trade_type = ?", params[:broker], TradeTypeEnum::SELL])
        @products = Trade.summarize_by_product(trades)
        render :json => @products
    end
end
