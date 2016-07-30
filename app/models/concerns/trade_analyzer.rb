class TradeAnalyzer
    def intialize(trades)
        @trades = trades
    end

    def analyze
        {
            trade_count: trade_count,
            new_remaining_days: new_trade_remaining_days_avg,
            settlement_remaining_days: settlement_trade_remaining_days_avg,
            holding_avg: holding_days_avg,
            max_gain_loss: max_gain_loss_amount,
            min_gain_loss: min_gain_loss_amount,
            avg_gain_loss: gain_loss_amount_avg,
            sd_gain_loss: gain_loss_amount_sd
        }
    end

    private
    def trade_count
        trades.count
    end

    def new_trade_remaining_days_avg
        new_trades = @trades.where(trade_type: TradeTypeEnum::BUY)
        remaining_days = new_trades.map {|t| t.sq_date - t.trade_datetime.to_date}
        remaining_days.avg
    end

    def settlement_trade_remaining_days_avg
        settlement_trades = @trades.where(trade_type: TradeTypeEnum::SELL)
        remaining_days = settlement_trades.map {|t| t.sq_date - t.trade_datetime.to_date}
        remaining_days.avg
    end

    def holding_days_avg
        settlement_trades = @trades.where(trade_type: TradeTypeEnum::SELL)
        holding_days = settlement_trades.map {|t| t.trade_datetime.to_date - t.buy_date}
        holding_days.avg
    end

    def max_gain_loss_amount
        @trades.maximum(:gain_loss_amount)
    end

    def min_gain_loss_amount
        @trades.minimum(:gain_loss_amount)
    end

    def gain_loss_amount_avg
        amounts = @trades.where(trade_type: TradeTypeEnum::SELL).map{|t| t.gain_loss_amount}
        amounts.avg
    end

    def gain_loss_amount_sd
        amounts = @trades.where(trade_type: TradeTypeEnum::SELL).map{|t| t.gain_loss_amount}
        amounts.sd
    end
end