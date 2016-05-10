class ImportCsvController < ApplicationController
  def import
    # broker = params[:broker]
    trades = Trade.create_from_csv(params[:file])
    logger.info('import req recieved')
    render :json => trades
  end
end
