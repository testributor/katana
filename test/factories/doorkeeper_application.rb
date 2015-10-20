FactoryGirl.define do
  factory :doorkeeper_application, class: Doorkeeper::Application do
    sequence(:name) { |n| "Application #{n}" }
    redirect_uri "https://www.example.com"
    association :owner, factory: :project
  end
end
