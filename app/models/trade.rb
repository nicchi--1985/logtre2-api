class Trade < ApplicationRecord
  enum broker_no: {sbi: 0, gmo: 1, rakuten: 2}
  enum product_no: {put: 0, call: 1, mini225: 2, large225: 3, jpx: 4, topix: 5, topixmini: 6, nikkei6: 7, dow: 8}
  # broker_trade_no 証券会社が採番した取引識別番号
  def self.create_from_csv(user_id, broker, file)
    args_list = build_args_from_csv(broker, file)
    args_list.each do |args|
      self.create_with(args)
          .find_or_create_by(user_id: user_id.to_i, broker_trade_no: args[:broker_trade_no])
    end
  end
  
  # 取引サマリを返す
  def self.summarize(trades)
    trade_count = trades.count
    selling_trades = trades.where(["trade_type = ?", TradeTypeEnum::SELL])
    trade_amount_total = selling_trades.inject(0) {|sum, trade| sum + (trade.trade_amount - trade.gain_loss_amount)}
    gain_loss_total = selling_trades.sum(:gain_loss_amount)
    roi = (gain_loss_total.to_f / trade_amount_total.to_f * 100).round(2)
    summary = {
      :gain_loss => "#{gain_loss_total} 円",
      :roi => "#{roi} %",
      :trade_count => "#{trade_count} 回"
    }
  end

  # 商品毎の取引サマリを返す
  PRODUCT_NAME = {
        "put" => "２２５ＯＰプット",
        "call" => "２２５ＯＰコール",
        "mini225" => "ミニ２２５先物",
        "large225" => "２２５先物",
        "jpx" => "ＪＰＸ日経４００先物",
        "topix" => "ＴＯＰＩＸ先物",
        "topixmini" => "ミニＴＯＰＩＸ先物",
        "nikkei6" => "日経平均Ⅵ先物",
        "dow" => "ＮＹダウ先物"
    }
  def self.summarize_by_product(trades)
    summary = [] # [{name: "product_name", gain_loss_total: "xxxx円"}]
    sums = trades.group(:product_no).sum(:gain_loss_amount)
    sums.each do |sum|
      summary.push({name: sum[0], disp_name: PRODUCT_NAME[sum[0]], gain_loss_total: sum[1]})
    end
    return summary
  end

  private_class_method
    # SBI証券出力のcsvをparseする
    def self.build_args_from_csv(broker, file)
      parser = CSVParser.get_csv_parser(broker)
      args_list = parser.build_args_list(file)
    end
end
