FactoryGirl.define do
  factory :doorkeeper_application, class: Doorkeeper::Application do
    sequence(:name) { |n| "Application #{n}" }
    redirect_uri "https://www.example.com"
    association :owner, factory: :project

    after(:create) do |doorkeeper_application, evaluator|
      FactoryGirl.create(:worker_group,
        friendly_name: "Worker group for #{doorkeeper_application.name}",
        oauth_application: doorkeeper_application)
    end
  end
end
