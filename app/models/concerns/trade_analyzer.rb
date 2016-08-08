class TradeAnalyzer
    # データが溜まるまではログトレが規定した値で正規化
    # 主タイプはバランス型で決め打ち
    RADAR_RANGE = 10
    NORMALIZE_FACTOR = {
        "balance": {
            "long": {
                "trade_count": {avg: 2.0, vari: 0.2},
                "new_remaining_days": {avg: 90, vari: 0.2},
                "settlement_remaining_days": {avg: 1, vari: 0.2},
                "holding_avg": {avg: 100, vari: 0.2},
                "max_gain_loss": {avg: 0, vari: 0.2, max: 500000, min: -500000},
                "min_gain_loss": {avg: 0, vari: 0.2, max: 500000, min: -500000},
                "avg_gain_loss": {avg: 0, vari: 0.2, max: 500000, min: -500000}
            },
            "mid": {
                "trade_count": {avg: 6.0, vari: 0.2},
                "new_remaining_days": {avg: 60, vari: 0.2},
                "settlement_remaining_days": {avg: 30, vari: 0.2},
                "holding_avg": {avg: 30, vari: 0.2},
                "max_gain_loss": {avg: 0, vari: 0.2, max: 1000000, min: -1000000},
                "min_gain_loss": {avg: 0, vari: 0.2, max: 1000000, min: -1000000},
                "avg_gain_loss": {avg: 0, vari: 0.2, max: 1000000, min: -1000000}
            },
            "short": {
                "trade_count": {avg: 26.0, vari: 0.2},
                "new_remaining_days": {avg: 30, vari: 0.2},
                "settlement_remaining_days": {avg: 23, vari: 0.2},
                "holding_avg": {avg: 7, vari: 0.2},
                "max_gain_loss": {avg: 0, vari: 0.2, max: 2000000, min: -2000000},
                "min_gain_loss": {avg: 0, vari: 0.2, max: 2000000, min: -2000000},
                "avg_gain_loss": {avg: 0, vari: 0.2, max: 2000000, min: -2000000}
            },
            "day": {
                "trade_count": {avg: 180.0, vari: 0.2},
                "new_remaining_days": {avg: 15, vari: 0.2},
                "settlement_remaining_days": {avg: 14, vari: 0.2},
                "holding_avg": {avg: 1, vari: 0.2},
                "max_gain_loss": {avg: 0, vari: 0.2, max: 5000000, min: -5000000},
                "min_gain_loss": {avg: 0, vari: 0.2, max: 5000000, min: -5000000},
                "avg_gain_loss": {avg: 0, vari: 0.2, max: 5000000, min: -5000000}
            }
        }
    }
    def initialize(trades)
        @trades = trades
        @holding_avg = holding_days_avg
        @sub_type = trader_sub_type
    end

    def analyze
        return [
            {
                name: "期間中取引回数",
                value: normalize("trade_count", trade_count),
                real_val: trade_count
            },
            {
                name: "SQまでの残日数(新規)",
                value: normalize("new_remaining_days", new_trade_remaining_days_avg),
                real_val: new_trade_remaining_days_avg

            },
            {
                name: "SQまでの残日数(決済)",
                value: normalize("settlement_remaining_days", settlement_trade_remaining_days_avg),
                real_val: settlement_trade_remaining_days_avg
            },
            {
                name: "平均保有期間",
                value: normalize("holding_avg", holding_days_avg),
                real_val: holding_days_avg
            },
            {
                name: "損益最高",
                value: norm_gain_loss("max_gain_loss", max_gain_loss_amount),
                real_val: max_gain_loss_amount
            },
            {
                name: "損益最低",
                value: norm_gain_loss("min_gain_loss", min_gain_loss_amount),
                real_val: min_gain_loss_amount
            },
            {
                name: "損益平均",
                value: norm_gain_loss("avg_gain_loss", gain_loss_amount_avg),
                real_val: gain_loss_amount_avg
            },
        ]
    end

    private
    def trader_sub_type
        if @holding_avg <= 1
            return "day"
        elsif @holding_avg <= 7
            return "short"
        elsif @holding_avg <= 30
            return "mid"
        else
            return "long"
        end 
    end

    def normalize(index_name, index_value)
        factors = NORMALIZE_FACTOR['balance'.to_sym][@sub_type.to_sym][index_name.to_sym]
        avg = factors[:avg]
        vari = factors[:vari]

        Rails.logger.debug("name: #{index_name}, value: #{index_value}, avg: #{avg}")
        norm_index = (index_value * (RADAR_RANGE / 2)) / avg
        return norm_index.round(1)
    end

    def offset_gain_loss(gain_loss, min)
        return gain_loss - min
    end

    def norm_gain_loss(index_name, index_value)
        factors = NORMALIZE_FACTOR['balance'.to_sym][@sub_type.to_sym][index_name.to_sym]
        avg = factors[:avg]
        max = factors[:max]
        min = factors[:min]
        if index_name == "max_gain_loss"
            res = offset_gain_loss(index_value, min) * 5 / (max - min)
            return res.round(1)
        elsif index_name == "min_gain_loss"
            res = offset_gain_loss(index_value, min) * 5 / min.abs
            return res.round(1)
        elsif index_name == "avg_gain_loss"
            res = offset_gain_loss(index_value, min) * 5 / (avg - min)
            return res.round(1)
        else
            raise StandardError.new("does not how to normalize #{index_name}")
        end
    end

    def trade_count
        @trades.count
    end

    def new_trade_remaining_days_avg
        new_trades = @trades.where(["trade_type = ?",  TradeTypeEnum::BUY])
        remaining_days = new_trades.map {|t| t.sq_date - t.trade_datetime.to_date}
        remaining_days.avg
    end

    def settlement_trade_remaining_days_avg
        settlement_trades = @trades.where(["trade_type = ?", TradeTypeEnum::SELL])
        remaining_days = settlement_trades.map {|t| t.sq_date - t.trade_datetime.to_date}
        remaining_days.avg
    end

    def holding_days_avg
        settlement_trades = @trades.where(["trade_type = ?", TradeTypeEnum::SELL])
        holding_days = settlement_trades.map {|t| t.trade_datetime.to_date - t.buy_date}
        holding_days.avg
    end

    def max_gain_loss_amount
        @trades.where(["trade_type = ?", TradeTypeEnum::SELL]).maximum(:gain_loss_amount)
    end

    def min_gain_loss_amount
        @trades.where(["trade_type = ?", TradeTypeEnum::SELL]).minimum(:gain_loss_amount)
    end

    def gain_loss_amount_avg
        amounts = @trades.where(["trade_type = ?", TradeTypeEnum::SELL]).map{|t| t.gain_loss_amount}
        amounts.avg
    end
end
