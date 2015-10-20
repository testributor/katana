FactoryGirl.define do
  factory :project do
    sequence(:name) { |n| "ACME #{n}" }
    association :user
    sequence(:repository_id) { |n| n }
  end
end
