class IndexCalculator
    def self.trade_count_in_term(trades)
        trades.count
    end

    def self.new_trade_remaining_days_avg(trades)
        new_trades = trades.where(trade_type: TradeTypeEnum::BUY)
        remaining_days = new_trades.map {|t| t.sq_date - t.trade_datetime.to_date}
        remaining_days.avg
    end

    def self.settlement_trade_remaining_days_avg(trades)
        settlement_trades = trades.where(trade_type: TradeTypeEnum::SELL)
        remaining_days = settlement_trades.map {|t| t.sq_date - t.trade_datetime.to_date}
        remaining_days.avg
    end

    def self.holding_days_avg(trades)
        settlement_trades = trades.where(trade_type: TradeTypeEnum::SELL)
        holding_days = settlement_trades.map {|t| t.trade_datetime.to_date - t.buy_date}
        holding_days.avg
    end

    def self.max_gain_loss_amount(trades)
        trades.maximum(:gain_loss_amount)
    end

    def self.min_gain_loss_amount(trades)
        trades.minimum(:gain_loss_amount)
    end

    def self.gain_loss_amount_avg(trades)
        amounts = trades.where(trade_type: TradeTypeEnum::SELL).map{|t| t.gain_loss_amount}
        amounts.avg
    end

    def self.gain_loss_amount_sd(trades)
        amounts = trades.where(trade_type: TradeTypeEnum::SELL).map{|t| t.gain_loss_amount}
        amounts.sd
    end
end