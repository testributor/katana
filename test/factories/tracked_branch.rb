FactoryGirl.define do
  factory :tracked_branch do
    association :project
    sequence(:branch_name){|n| "tracked_branch_#{n}"}
  end
end
