FactoryGirl.define do
  factory :project_file do
    sequence(:path) { |n| "test/models/model_#{n}_test.rb" }
    contents <<-YAML
      each:
        pattern: "test/.*_test.rb$"
        command: 'bin/rake test %{file}'
    YAML
    association :project
  end
end
