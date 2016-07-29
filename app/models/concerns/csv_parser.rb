require 'logger'

class CSVParser
    def self.get_csv_parser(broker)
      case broker
      when "sbi" then
        return SBICSVParser.new(broker)
      else
        raise "parser for #{broker} is not implemented"
      end
    end
end

class SBICSVParser < CSVParser
    def initialize(broker)
        @broker = broker
        @sbi_option_header_jp = [
            "約定番号", "約定日時", "市場", "銘柄", "取引", "約定価格", "約定数量", \
            "手数料", "消費税", "約定金額", "取引日", "受渡金額", "受渡日", "新規建日", \
            "新規建単価", "新規建手数料", "新規建消費税", "決済損益", "SQ日", "注文受付区分"
            ]
    end

    def build_args_list(file)
        args_list = []
        CSV.foreach(file.path, headers: true, encoding: "Shift_JIS:UTF-8") do |row|
            # 取引データでないrowを排除
            if row.length == 20 then
                values = row.fields
                # header row でないなら処理する
                if values != @sbi_option_header_jp then
                    ary = [@sbi_option_header_jp, values].transpose
                    ary = Hash[*ary.flatten]
                    args = {
                    "broker_no": @broker,
                    "broker_trade_no": ary['約定番号'],
                    "trade_type": trade_type_no(ary['取引']),
                    "trade_datetime": ary['約定日時'].to_datetime,
                    "brand_name": ary['銘柄'],
                    "product_no": parse_product_no(ary['銘柄']),
                    "product_price": ary['約定価格'].to_i,
                    "trade_quantity": ary['約定数量'].to_i,
                    "trade_amount": ary['約定金額'].to_i,
                    "gain_loss_amount": ary['決済損益'].to_i,
                    "sq_date": ary['SQ日'].to_date,
                    "buy_date": parse_buy_date(ary['新規建日'])
                    }
                    args_list.push(args)
                end
            end
        end
        return args_list
    end

    private
    def trade_type_no(type_str)
      if type_str.include?("買")
        TradeTypeEnum::BUY
      elsif type_str.include?("売")
        TradeTypeEnum::SELL
      else
        TradeTypeEnum::UNKOWN
      end
    end

    def parse_product_no(brand_name)
        return :put if brand_name.include?("プット")
        return :call if brand_name.include?("コール")
        return :nikkei6 if brand_name.include?("日経平均")
        return :jpx if brand_name.include?("ＪＰＸ")
        return :dow if brand_name.include?("ＮＹ")
        if brand_name.include?("TOPIX") and brand_name.include?("ミニ") then
            return :topixmini
        else
            return :topix
        end
        if brand_name.include?("２２５先物") and brand_name.include?("ミニ") then
            return :mini225
        else
            return :large225
        end
    end

    def parse_buy_date(buy_date)
        begin
            buy_date.to_date
        rescue => e
            Logger.new(STDOUT).warn('parsing #{buy_date} failed: #{e.message}')
            return nil
        end
    end
end