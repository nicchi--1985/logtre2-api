class TradesController < ApplicationController
  def index
    trades = Trade.all()
    render :json => trades
  end
  def summary
    term_days = 360
    trades = Trade.where(["user_id = ? and trade_datetime > ? and gain_loss_amount != 0", current_user.id, Date.today - term_days])
    summary = Trade.summarize(trades=trades)
    render :json => summary
  end
end
