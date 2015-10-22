FactoryGirl.define do
  factory :test_job do
    association :test_run
    sequence(:file_name){|n| "test/models/model_#{n}_test.rb"}
    result ''
    status 0
    test_errors 0
    failures 0
    count 0
    assertions 0
    skips 0
  end
end
