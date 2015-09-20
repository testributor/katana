FactoryGirl.define do
  factory :project_role do
    sequence(:name) { |n| "Project role #{n}" }
  end
end
