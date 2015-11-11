FactoryGirl.define do
  factory :project_wizard do
    association :user
    repo_name "testributor"
    selected_technologies %w(postgres9.3 redis)
    branch_names %w(master new_branch)
    testributor_yml "each: blah"
  end
end
