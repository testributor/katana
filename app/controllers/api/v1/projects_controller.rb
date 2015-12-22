module Api
  module V1
    class ProjectsController < ApiController
      def current
        render json: current_project
      end

      def beacon
        render json: "OK", status: 200
      end
    end
  end
end
