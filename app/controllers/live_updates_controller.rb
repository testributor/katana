# This controller and the Broadcaster model are part of the implementation of
# push events. The implementation is base on the idea described in this article:
# http://www.pivotaltracker.com/community/tracker-blog/one-weird-trick-to-switch-from-polling-to-push
class LiveUpdatesController < ApplicationController
  # Checks if the current_user is authorized for live updates on the requested
  # resource and directs the socket.io server to include the specified socket
  # to any updates on this resource. The server is informed through Redis
  # Pub/Sub system.
  def subscribe
    klass, id = params[:resource_id].split("#")
    id = id.to_i

    if whitelisted_params.include?(klass) && params[:uid].present?
      resource = klass.constantize.find(id)

      begin
        authorize! :read_live_updates, resource

        # User is authorized for this resource, therefore add socket_id to
        # subscribers.
        Broadcaster.subscribe(
          params[:uid], resource.redis_live_update_resource_key
        )

        head :ok
      rescue CanCan::AccessDenied
        render json: { errors: 'Access denied' },
          status: :unprocessable_entity
      end
    else
      render json: { errors: 'Param is not whitelisted' },
        status: :unprocessable_entity
    end
  end

  def whitelisted_params
    [Project, TestRun, TestJob, TrackedBranch].map(&:to_s)
  end
end
