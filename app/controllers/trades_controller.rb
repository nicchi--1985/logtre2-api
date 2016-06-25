class TradesController < ApplicationController
  skip_before_action :authenticate_request!
  def index
    logger.debug(request.env)
    trades = Trade.all()
    render :json => trades
  end
end
