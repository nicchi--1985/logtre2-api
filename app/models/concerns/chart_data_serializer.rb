class ChartDataSerializer
    def self.serialize(trades)
        trade_data = trades.map {|t| {x: t.trade_datetime.strftime("%Y-%m-%d"), y: t.gain_loss_amount}}
        time_unit = select_time_unit(trades)
        return {data: trade_data, time_unit: time_unit}
    end

    private
    def self.select_time_unit(trades)
        max = trades.maximum(:trade_datetime)
        min = trades.minimum(:trade_datetime)
        # 取引日の幅が１ヶ月以内ならtime_unitをweekとする
        if max.year == min.year && max.month == min.month then
            return "week"
        else
            return "month"
        end
    end
end