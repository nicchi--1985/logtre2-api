class ImportCsvController < ApplicationController
  def index
    render :json => {'msg': "hello #{@current_user.name}"}
  end
  def import
    # broker = params[:broker]
    trades = Trade.create_from_csv(current_user.id, params[:stockComp],params[:file])
    logger.info('import req recieved')
    render :json => trades
  end
end
