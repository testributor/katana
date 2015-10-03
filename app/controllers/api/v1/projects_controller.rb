module Api
  module V1
    class ProjectsController < ApiController
      def current
        render json: current_project
      end
    end
  end
end
