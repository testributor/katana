require 'test_helper'

class WorkerGroupManagementFeatureTest < Capybara::Rails::TestCase
  describe "when project's repository provider is 'bare_repo'" do
    let(:project) do
      FactoryGirl.create(:project, repository_provider: "bare_repo",
                        repository_url: "git@github.com:ispyropoulos/katana.git")
    end
    let(:owner) { project.user }

    before do
      FactoryGirl.create(:doorkeeper_application, owner: project)
      login_as owner, scope: :user
      visit worker_setup_project_settings_path(project)
    end

    it "doesn't show 'Reset SSH key' CTA" do
      page.must_have_text project.worker_groups.first.friendly_name
      page.wont_have_selector(".worker-group-actions a", text: "Reset SSH key")
    end

    it "shows the SSH key field on the edit modal", js: true do
      find(".worker-group-info .btn", text: "EDIT").click
      page.must_have_selector(
        "#edit_worker_group_#{project.worker_groups.first.id} .worker_group_ssh_key_private",
        visible: true)
    end

    it "shows validation errors", js: true do
      find(".worker-group-info .btn", text: "EDIT").click
      fill_in "worker_group_ssh_key_private", with: "invalid_key"
      find(".modal-footer .btn[value='Save']").click
      page.must_have_content "Ssh key private is invalid"
    end

    it "updates the values when no validation error exists", js: true do
      new_ssh_key = FactoryGirl.build(:worker_group).ssh_key_private.strip
      find(".worker-group-info .btn", text: "EDIT").click
      fill_in "worker_group_ssh_key_private", with: new_ssh_key
      fill_in "worker_group_friendly_name", with: "The new friendly name"
      find(".modal-footer .btn[value='Save']").click
      page.wont_have_content "Ssh key private is invalid"
      worker_group = project.worker_groups.first.reload
      worker_group.friendly_name.must_equal "The new friendly name"
      worker_group.ssh_key_private.gsub(/\r|\n/, "").must_equal(
        new_ssh_key.gsub(/\r|\n/, ""))
    end

    it "shows the SSH key field on creation modal", js: true do
      click_on "New worker group"
      page.must_have_selector(
        "#new_worker_group .worker_group_ssh_key_private", visible: true)
    end

    it "creates a new worker group when no validation error exists", js: true do
      new_ssh_key = FactoryGirl.build(:worker_group).ssh_key_private.strip
      old_count = project.worker_groups.count
      click_on "New worker group"
      fill_in "worker_group_ssh_key_private", with: new_ssh_key
      fill_in "worker_group_friendly_name", with: "The new friendly name"
      find(".modal-footer .btn[value='Save']").click
      project.worker_groups.count.must_equal(old_count + 1)
      worker_group = project.worker_groups.last
      worker_group.friendly_name.must_equal "The new friendly name"
      worker_group.ssh_key_private.gsub(/\r|\n/, "").must_equal(
        new_ssh_key.gsub(/\r|\n/, ""))
    end
  end

  describe "when project's repository provider is not 'bare_repo'" do
    let(:project) do
      FactoryGirl.create(:project, repository_provider: "github",
                        repository_url: "git@github.com:ispyropoulos/katana.git")
    end
    let(:owner) { project.user }

    before do
      FactoryGirl.create(:doorkeeper_application, owner: project)
      login_as owner, scope: :user
      visit worker_setup_project_settings_path(project)
    end

    it "shows 'Reset SSH key' CTA" do
      page.must_have_text project.worker_groups.first.friendly_name
      page.must_have_selector(".worker-group-info a", text: "Reset SSH key")
    end

    it "doesn't show the SSH key field on the edit modal", js: true do
      find(".worker-group-info .btn", text: "EDIT").click
      page.wont_have_selector(
        "#edit_worker_group_#{project.worker_groups.first.id} .worker_group_ssh_key_private")
    end

    it "shows validation errors", js: true do
      find(".worker-group-info .btn", text: "EDIT").click
      fill_in "worker_group_friendly_name", with: ""
      find(".modal-footer .btn[value='Save']").click
      page.must_have_content "Friendly name can't be blank"
    end

    it "updates the values when no validation error exists", js: true do
      new_ssh_key = FactoryGirl.build(:worker_group).ssh_key_private.strip
      find(".worker-group-info .btn", text: "EDIT").click
      fill_in "worker_group_friendly_name", with: "The new friendly name"
      find(".modal-footer .btn[value='Save']").click
      worker_group = project.worker_groups.first.reload
      worker_group.friendly_name.must_equal "The new friendly name"
    end
  end
end
