class TradesController < ApplicationController
  skip_before_action :authenticate_request!
  def index
    trades = Trade.all()
    render :json => trades
  end
end
