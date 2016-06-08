require 'test_helper'

class DockerComposeFeatureTest < Capybara::Rails::TestCase
  describe "when the user clicks 'Save'" do
    let(:project) { FactoryGirl.create(:project) }
    let(:user) { project.user }

    before do
      FactoryGirl.create(:doorkeeper_application, owner: project)
      login_as user, scope: :user
      visit worker_setup_project_settings_path(project)
    end

    describe "and there are no validation errors" do
      before do
        page.driver.execute_script(
          "current_page.editor.setValue('my_special_key: 23');")
      end

      it "updates the docker-compose.yml preview", js: true do
        click_on "Save"
        page.find(".docker-compose-preview").must_have_content "my_special_key: 23"
      end
    end

    describe "and there are validation errors" do
      before do
        page.driver.execute_script(
          "current_page.editor.setValue('asdf asdf asdf');")
      end

      it "shows the validation error instead of the docker-compose.yml preview", js: true do
        click_on "Save"
        page.find(".docker-compose-preview").must_have_content "Custom docker compose yml format not compatible"
      end

      it "shows the validation error instead of the docker-compose.yml preview", js: true do
        contents = <<-TEXT
          asdf:
          asdfasdf
        TEXT

        page.driver.execute_script(
          "current_page.editor.setValue(#{contents.inspect});")

        click_on "Save"
        page.find(".docker-compose-preview").must_have_content "Custom docker compose yml syntax error"
      end
    end
  end
end
