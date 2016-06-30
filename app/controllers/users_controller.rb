class UsersController < ApplicationController
    def get_current_user
        logger.debug("user=#{current_user.to_json}")
        render json: current_user
    end
end
