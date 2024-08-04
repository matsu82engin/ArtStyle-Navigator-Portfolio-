module Api
  module V1
    class SessionsController < DeviseTokenAuth::SessionsController
      include UserSessionizeService
    end
  end
end
