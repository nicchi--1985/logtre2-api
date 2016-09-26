class ImportCsvController < ApplicationController
  def index
    render :json => {'msg': "hello #{@current_user.name}"}
  end
  def import
    trades = Trade.create_from_csv(current_user.id, params[:broker], params[:file])
    render :json => trades
  end
end
