require 'test_helper'

class SalespageFeatureTest < Capybara::Rails::TestCase
  it "displays info in homepage" do
    visit root_path
    page.must_have_content "Sign up for Beta"
  end
end
