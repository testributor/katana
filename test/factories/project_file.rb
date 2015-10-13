FactoryGirl.define do
  factory :project_file do
    sequence(:path) { |n| "test/models/model_#{n}_test.rb" }
    contents "dummy content"
    association :project
  end
end
