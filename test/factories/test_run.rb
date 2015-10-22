FactoryGirl.define do
  factory :test_run do
    association :tracked_branch
    commit_sha "123456"
    status 0
  end
end
