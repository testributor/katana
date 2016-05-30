require 'test_helper'

class TopicSubscriberTest < ActiveSupport::TestCase
  describe "#subscribe" do
    let(:first_project) { FactoryGirl.create(:project) }
    let(:last_project) do
      FactoryGirl.create(:project, user: first_project.user)
    end
    let(:project_from_other_user) { FactoryGirl.create(:project) }
    let(:subscriptions) do
      {
        "Project" => { "ids" => [ first_project.id, last_project.id, -1,
                                  "random", nil, "", project_from_other_user.id
                                ]
                     },
        "" => 1,
        "NoWhitelistedKlass" => 4
      }
    end

    before do
      first_project.user.update_column(:projects_limit, 3)
    end

    it "returns successful_subscriptions when socket_id is not nil" do
      socket_id = "1adf334a55s"
      topic_subscriber = TopicSubscriber.new(first_project.user, socket_id)
      successful_subscriptions = topic_subscriber.subscribe(subscriptions)
      successful_subscriptions.
        must_equal({ "Project" => [first_project.id, last_project.id] })
    end

    it "calls Broadcaster.subscribe with correct arguments on non nil socket_id" do
      socket_id = "1adf334a55s"
      topic_subscriber = TopicSubscriber.new(first_project.user, socket_id)
      successful_subscriptions_array = [
        "Project##{first_project.id}", "Project##{last_project.id}"
      ]
      Broadcaster.expects(:subscribe).
        with(socket_id, successful_subscriptions_array).once
      topic_subscriber.subscribe(subscriptions)
    end

    it "returns {} and doesn't subscribe when socket_id is nil" do
      socket_id = nil
      topic_subscriber = TopicSubscriber.new(first_project.user, socket_id)
      Broadcaster.expects(:subscribe).never
      successful_subscriptions = topic_subscriber.subscribe(subscriptions)
      successful_subscriptions.must_equal({})
    end
  end

  describe "#authorized_actions_to_subscribe" do
    let(:irrelevant_user) { FactoryGirl.create(:user) }
    let(:_test_run) { FactoryGirl.create(:testributor_run) }
    let(:_test_run_subscriptions) do
      {
        "TestRun" => { "ids" => [ _test_run.id ],
                        "project_id" => _test_run.project.id,
                        "actions" => ["read"]
                     },
      }
    end
    let(:wrong_test_run_subscriptions) do
      {
        "TestRun" => { "ids" => [ _test_run.id ],
                        "project_id" => 0,
                        "actions" => ["read"]
                     },
      }
    end

    it 'subscribes the user to the requested action' do
      socket_id = "1adf334a55s"
      topic_subscriber = TopicSubscriber.new(_test_run.project.user, socket_id)
      successful_subscriptions = topic_subscriber.subscribe(_test_run_subscriptions)
      successful_subscriptions.must_equal({ "TestRun"=> [_test_run.id, "read"] })
    end

    it 'does not subscribe the user to the requested action if user not in project' do
      socket_id = "1adf334a55s"
      topic_subscriber = TopicSubscriber.new(irrelevant_user, socket_id)
      successful_subscriptions = topic_subscriber.subscribe(_test_run_subscriptions)
      successful_subscriptions.must_equal({})
    end

    it 'does not subscribe the user if project_id is wrong' do
      socket_id = "1adf334a55s"
      topic_subscriber = TopicSubscriber.new(_test_run.project.user, socket_id)
      successful_subscriptions = topic_subscriber.subscribe(wrong_test_run_subscriptions)
      successful_subscriptions.must_equal({ "TestRun"=> [_test_run.id] })
    end
  end
end
