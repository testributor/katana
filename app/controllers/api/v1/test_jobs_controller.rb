module Api
  module V1
    class TestJobsController < ApiController
      def index
        respond_to do |f|
          f.json do
            results = current_project.tracked_branches.includes(:test_jobs).map do |c|
              c.test_jobs
            end.flatten

            render json: results
          end
        end
      end
    end
  end
end
