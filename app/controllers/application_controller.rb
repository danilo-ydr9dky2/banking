class ApplicationController < ActionController::API
    def not_found
        render status: :not_found
    end
end
