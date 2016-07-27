class IndexCalculator
    def self.trade_count_in_term(trades)
        trades.count
    end

    def self.new_trade_remaining_days_avg(trades)
        new_trades = trades.where(trade_type: TradeTypeEnum::BUY)
        remaining_days = new_trades.map {|t| t.sq_date - t.trade_datetime.to_date}
        avg = remaining_days.inject(0.0){|sum, day| sum + day} / remaining_days.size
    end

    def self.settlement_trade_remaining_days_avg(trades)
        new_trades = trades.where(trade_type: TradeTypeEnum::SELL)
        remaining_days = new_trades.map {|t| t.sq_date - t.trade_datetime.to_date}
        avg = remaining_days.inject(0.0){|sum, day| sum + day} / remaining_days.size
    end

    def self.holding_days_avg(trades)

    end

    def self.max_gain_loss_amount(trades)
        trades.maximum(:gain_loss_amount)
    end

    def self.min_gain_loss_amount(trades)
        trades.minimum(:gain_loss_amount)
    end

    def self.gain_loss_amount_avg(trades)
        trade_count = trades.where(trade_type: TradeTypeEnum::SELL).count
        total = trades.sum(:gain_loss_amount)
        avg = total / trade_count
    end

    def self.gain_loss_amount_sd(trades)
        amounts = trades.where(trade_type: TradeTypeEnum::SELL).map{|t| t.gain_loss_amount}
        count = amounts.size
        avg = amounts.inject(0.0){|sum, amount| sum + amount } / count
        var = amounts.reduce(0){|sum, amount| sum + (amount - avg) ** 2 } / (count - 1)
        sd = Math.sqrt(var)
    end
end