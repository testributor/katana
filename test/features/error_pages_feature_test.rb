require 'test_helper'

class ErrorPagesFeatureTest < Capybara::Rails::TestCase

  before do
    Rails.application.config.action_dispatch.show_exceptions = true
    Rails.application.config.consider_all_requests_local = false
  end

  after do
    Rails.application.config.action_dispatch.show_exceptions = false
    Rails.application.config.consider_all_requests_local = true
  end

  describe "#not_found" do
    describe 'when visiting a non existing page' do
      it 'displays a 404 page' do
        visit '/a_non_existing_page'
        page.must_have_content '404'
      end
    end
  end

  describe "#access_forbidden" do
    let(:user) { FactoryGirl.create(:user) }
    let(:project) { FactoryGirl.create(:project, is_private: false) }

    before do
      login_as user, scope: :user
    end

    describe 'when user visits a page that does not have access' do
      it 'displays a 403 page' do
        visit project_files_path(project_id: project.id)
        page.must_have_content '403'
      end
    end
  end
end
