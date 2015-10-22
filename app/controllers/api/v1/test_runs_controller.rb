module Api
  module V1
    class TestRunsController < ApiController
      def index
        respond_to do |f|
          f.json do
            results = current_project.tracked_branches.includes(:test_runs).map do |c|
              c.test_runs
            end.flatten

            render json: results
          end
        end
      end
    end
  end
end
