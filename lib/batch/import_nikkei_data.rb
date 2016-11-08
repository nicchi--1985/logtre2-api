class ImportNikkeiDataBatch
    @@logger = ActiveSupport::Logger.new(Rails.root.join("log/batch.log"))
    def self.import
        CSV.foreach('tmp/nikkei_data_file/nikkei.csv', encoding: "Shift_JIS:UTF-8") do |row|
            begin
                date = Date.strptime(row[0], '%Y/%m/%d')
                puts("#{date}, #{row[1]}, #{row[2]}, #{row[3]}, #{row[4]}")
                Nikkei.create do |n|
                    n.date = date
                    n.last_price = row[1].to_i
                    n.open_price = row[2].to_i
                    n.high_price = row[3].to_i
                    n.low_price = row[4].to_i
                end
            rescue ArgumentError => e
                # skip
            end
        end
    end
end

ImportNikkeiDataBatch.import