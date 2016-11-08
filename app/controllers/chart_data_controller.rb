class ChartDataController < ApplicationController
    skip_before_action :authenticate_request!
    def nikkei
        binding.pry
    end
end
