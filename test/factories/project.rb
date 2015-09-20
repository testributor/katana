FactoryGirl.define do
  factory :project do
    sequence(:name) { |n| "ACME #{n}" }
    association :user
  end
end
