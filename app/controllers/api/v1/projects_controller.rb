module Api
  module V1
    class ProjectsController < ApiController
      # We ignore counting active workers for "current" action to avoid showing
      # the workers active during initialization. Initialization
      # take some time to complete and workers will appear as inactive
      # for some seconds.

      skip_before_action :worker_report, only: :current

      def current
        render json: current_project
      end

      def beacon
        head :ok
      end
    end
  end
end
