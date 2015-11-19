FactoryGirl.define do
  factory :user_invitation do
    sequence(:token) { |n| SecureRandom.hex(30) }
    sequence(:email) { |n| "john_doe_#{n}@example.com" }
    association :user
    association :project
  end
end
