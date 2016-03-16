module UsersApi
  module V1
    class UsersController < UsersApiController
      def current
        render json: {
          email: current_user.email
        }
      end
    end
  end
end
