class TopicSubscriber
  include CanCan::Ability

  def initialize(subscriber, socket_id)
    @socket_id = socket_id
    @subscriber = subscriber
    @ability = Ability.new(subscriber)
  end

  # Can accept multiple topics.
  # E.g. subscribe({TrackedBranch: { ids: [1,2,3],
  #                              actions: ['create', 'destroy'] },
  #                       Project: { ids: [3,4,5] })
  def subscribe(requested_subscriptions)
    return {} unless @socket_id

    subscriptions = {}
    requested_subscriptions.each do |klass, subscription_hash|
      ids = subscription_hash["ids"] if subscription_hash.try(:key?, "ids")
      actions = subscription_hash["actions"] if subscription_hash.try(:key?, "actions")
      project_id  = subscription_hash["project_id"] if subscription_hash.try(:key?, "project_id")

      authorized_ids = authorized_ids_to_subscribe(klass, ids)
      authorized_actions = authorized_actions_to_subscribe(klass, actions, project_id)

      authorizations = authorized_ids + Array(authorized_actions)
      subscriptions[klass] = authorizations if authorizations.any?
    end
    request_subscriptions(subscriptions)

    subscriptions
  end

  private

  def request_subscriptions(subscriptions)
    subscriptions_array = subscriptions.map do |klass, entities|
      entities.map { |entity| "#{klass}##{entity}" }
    end.flatten

    Broadcaster.subscribe(@socket_id, subscriptions_array)
  end

  def authorized_ids_to_subscribe(klass, ids)
    subscribed_resources = []

    Array(ids).each do
      next unless whitelisted_classes.include?(klass)
      resources = klass.constantize.where(id: ids)
      subscribed_resources = resources.select do |resource|
        @ability.can?(:read_live_updates, resource)
      end.map(&:id)
    end

    subscribed_resources
  end

  def authorized_actions_to_subscribe(klass, actions, project_id)
    return unless project_id

    project = Project.find_by(id: project_id)
    ability = Ability.new(@subscriber, project)

    actions.select do |action|
      ability.can?(action, klass.constantize)
    end
  end

  def whitelisted_classes
    [User, Project, TrackedBranch, TestRun, TestJob].map(&:to_s)
  end
end
