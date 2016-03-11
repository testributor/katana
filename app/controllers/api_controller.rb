class ApiController < ActionController::Base
  before_action :doorkeeper_authorize!
  before_action :worker_report

  private

  def current_project
    @current_project ||= doorkeeper_token.application.owner
  end

  def current_worker_group
    @current_worker_group ||= current_project.worker_groups.find_by(
      oauth_application_id: doorkeeper_token.application_id
    )
  end

  def worker_uuid
    request.headers['HTTP_WORKER_UUID']
  end

  def worker_uuid_redis_key
    "project_#{current_project.id}_worker_#{worker_uuid}" if worker_uuid
  end

  def worker_report
    return false unless worker_uuid_redis_key

    redis = Katana::Application.redis
    # Add an expiring key for the worker if not already there
    redis.setnx worker_uuid_redis_key, worker_uuid_redis_key
    redis.expire worker_uuid_redis_key, Project::ACTIVE_WORKER_THRESHOLD_SECONDS
    # Add the worker to the project's set of workers
    redis.sadd current_project.workers_redis_key, worker_uuid_redis_key
    # update the list of active workers on reports too to keep the list
    # size small. If we cleaned the list only on "reads" and a read did not come
    # for too long, we could end up bloating the memory (that might not be an
    # issue but better safe than sorry).
    current_project.update_active_workers
  end
end
