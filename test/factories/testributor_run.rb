FactoryGirl.define do
  factory :testributor_run, class: 'TestRun' do
    association :tracked_branch
    commit_sha "123456"
    status 0
  end
end
