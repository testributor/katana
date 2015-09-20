# https://github.com/metaskills/minitest-spec-rails/issues/49
namespace :test do
  Rails::TestTask.new("features" => "test:prepare") do |t|
    t.pattern = "test/features/**/*_test.rb"
  end
end
