class TradesController < ApplicationController
  def index
    trades = Trade.all()
    render :json => trades
  end
end
