FactoryGirl.define do
  factory :docker_image do
    sequence(:public_name) { |n| "Service #{n}" }
    sequence(:hub_image) { |n| "testributor/service_#{n}" }
    sequence(:standardized_name) { |n| "service_#{n}" }
    version '1.0'
    type "technology"

    trait :language do
      type "language"
    end
  end
end
