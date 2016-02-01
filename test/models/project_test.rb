require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  let(:project) { FactoryGirl.build(:project) }
  let(:owner) { project.user }
  let(:new_owner) { FactoryGirl.create(:user) }

  describe "technologies validations" do
    subject { FactoryGirl.create(:project) }

    let(:postgres_9_3) do
      FactoryGirl.create(:docker_image,
                         standardized_name: "postgres", version: "9.3")
    end

    let(:postgres_9_4) do
      FactoryGirl.create(:docker_image,
                         standardized_name: "postgres", version: "9.4")
    end

    it "validates uniqueness of technology standardized names" do
      ->{ subject.technologies = [postgres_9_3, postgres_9_4] }.
        must_raise(ActiveRecord::RecordInvalid)
    end
  end

  describe "project limit on user validation" do
    it "doesn't get called when user id hasn't changed" do
      owner.update_column(:projects_limit, 2)
      owner.reload
      project.save!
      project.expects(:check_user_limit).never
      project.save!
    end

    it "gets called when user id has changed" do
      owner.update_column(:projects_limit, 2)
      owner.reload
      project.user = new_owner
      project.expects(:check_user_limit).once
      project.save!
    end

    it "gets called when project is created" do
      project = Project.new(name: "Test", user: owner)
      project.expects(:check_user_limit).once
      project.save!
    end

    it "is valid if projects limit is greater than user's projects" do
      owner.update_column(:projects_limit, 2)
      owner.reload

      project.valid?.must_equal true
    end

    it "is valid if projects limit is equal to user's projects" do
      owner.update_column(:projects_limit, 1)
      owner.reload

      project.valid?.must_equal true
    end

    it "is invalid if projects limit is less than user's projects" do
      owner.update_column(:projects_limit, 0)
      owner.reload

      project.valid?.must_equal false
      project.errors.keys.must_include :base
    end
  end

  describe "invited_users association" do
    let(:invited_user) do
      FactoryGirl.create(:user_invitation, project: project).user
    end

    before { invited_user }

    it "returns users with invitations" do
      project.invited_users.must_equal [invited_user]
    end

    describe "after user accepting the invitation" do
      before do
        invited_user.user_invitations.first.accept!(invited_user)
      end

      it "still returns the invited user" do
        project.reload.invited_users.must_equal [invited_user]
      end
    end
  end

  describe 'creation of build_commands file' do
    it "creates a build commands file after creation" do
      user = FactoryGirl.create(:user)
      project = Project.create(name: "Test project", user: user)
      project.reload.project_files.pluck(:path).
        must_equal [ProjectFile::BUILD_COMMANDS_PATH]
    end
  end

  describe "to_param" do
    it "generates a simple/valid name for urls" do
      project = Project.new(name: "This.is|an|ugly.and^complex(name)@*&^*&^*for'a`project")
      project.to_param.must_equal "-this-is-an-ugly-and-complex-name-for-a-project"
    end
  end
end
