class Trade < ApplicationRecord
  # broker_no => 1:SBI
  # broker_trade_no 証券会社が採番した取引識別番号
  def self.create_from_csv(user_id, stockComp, file)
    args_list = build_args_from_sbi_csv(user_id, stockComp, file)
    args_list.each do |args|
      self.create_with(args)
          .find_or_create_by(user_id: args[:user_id], broker_trade_no: args[:broker_trade_no])
    end
  end
  
  def self.summarize(trades)
    trade_amount_total = trades.inject(0) {|sum, trade| sum + (trade.trade_amount - trade.gain_loss_amount)}
    gain_loss_total = trades.sum(:gain_loss_amount)
    trade_count = trades.count
    roi = (gain_loss_total.to_f / trade_amount_total.to_f * 100).round(2)
    summary = {
      :gain_loss => "#{gain_loss_total} 円",
      :roi => "#{roi} %",
      :trade_count => "#{trade_count} 回"
    }
  end

  private_class_method
    # SBI証券出力のcsvをparseする
    def self.build_args_from_sbi_csv(user_id, stockComp, file)
      args_list = []
      CSV.foreach(file.path, headers: true, encoding: "Shift_JIS:UTF-8") do |row|
        if row.length == 20 then
          values = row.fields
          if values != @@sbi_option_header_jp then
            ary = [@@sbi_option_header_jp, values].transpose
            ary = Hash[*ary.flatten]
            args = {
              "user_id": user_id,
              "broker_no": stockComp.to_i,
              "broker_trade_no": ary['約定番号'],
              "trade_type": trade_type_no(ary['取引']),
              "trade_datetime": ary['約定日時'].to_datetime,
              "brand_name": ary['銘柄'],
              "product_price": ary['約定価格'].to_i,
              "trade_quantity": ary['約定数量'].to_i,
              "trade_amount": ary['約定金額'].to_i,
              "gain_loss_amount": ary['決済損益'].to_i,
              "sq_date": ary['SQ日'].to_date
            }
            args_list.push(args)
          end
        end
      end
      return args_list
    end

    def self.trade_type_no(type_str)
      if type_str.include?("買")
        TradeTypeEnum::BUY
      elsif type_str.include?("売")
        TradeTypeEnum::SELL
      else
        TradeTypeEnum::UNKOWN
      end
    end

  @@sbi_option_header_jp = [
    "約定番号",
    "約定日時",
    "市場",
    "銘柄",
    "取引",
    "約定価格",
    "約定数量",
    "手数料",
    "消費税",
    "約定金額",
    "取引日",
    "受渡金額",
    "受渡日",
    "新規建日",
    "新規建単価",
    "新規建手数料",
    "新規建消費税",
    "決済損益",
    "SQ日",
    "注文受付区分"
  ]
end
