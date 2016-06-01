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

      authorizations = authorized_ids + authorized_actions.to_a
      subscriptions[klass] = authorizations if authorizations.any?
    end

    subscriptions.each do |klass, value|
      Broadcaster.subscribe(@socket_id, value)
    end

    subscriptions
  end

  private

  def authorized_ids_to_subscribe(klass, ids)
    return [] unless whitelisted_classes.include?(klass)

    klass.constantize.where(id: ids).inject([]) do |result, resource|
      if @ability.can?(:read_live_updates, resource)
        result << "#{klass}##{resource.id}"
      end

      result
    end
  end

  def authorized_actions_to_subscribe(klass, actions, project_id)
    return unless project_id

    project = Project.find_by(id: project_id)
    ability = Ability.new(@subscriber, project)

    actions.inject([]) do |result, action|
      if whitelisted_actions.include?(action) &&
        whitelisted_classes.include?(klass) &&
        ability.can?(:read_live_updates, project)

        # project exists or the ability above won't pass
        result << "Project##{project.id}##{klass}##{action}"
      end

      result
    end
  end

  def whitelisted_classes
    [User, Project, TrackedBranch, TestRun, TestJob].map(&:to_s)
  end

  def whitelisted_actions
    ['create']
  end
end
