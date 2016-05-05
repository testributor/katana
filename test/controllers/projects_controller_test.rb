require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  let(:project) { FactoryGirl.create(:project) }
  let(:owner) { project.user }
  let(:user) { FactoryGirl.create(:user) }
  let(:member) do
    project.members << (user = FactoryGirl.create(:user))
    user
  end
  let(:language) { FactoryGirl.create(:docker_image, :language) }
  let(:technology) { FactoryGirl.create(:docker_image) }

  describe 'when user is registered' do
    before do
      request.env["HTTP_REFERER"] = "previous_path"
      sign_in :user, owner
    end

    describe "PATCH#update" do
      describe 'when user is the owner' do
        it "updates docker_image_id when Project#valid?" do
          project_params = {
            id: project.id, project: { docker_image_id: language.id } }
          patch :update, project_params

          project.reload
          project.docker_image_id.must_equal language.id
        end

        it "updates technology_ids when Project#valid?" do
          project_params = {
            id: project.id,
            project: {
              docker_image_id: language.id,
              technology_ids: [technology.id]}
          }
          patch :update, project_params

          project.reload
          project.technology_ids.must_equal [technology.id]
        end

        it "updates repository_url when Project#valid?" do
          project_params = {
            id: project.id,
            project: { repository_url: "this_is_the_projects_new_home" }
          }
          patch :update, project_params

          project.reload
          project.repository_url.must_equal "this_is_the_projects_new_home"
        end
      end

      describe 'when user is a member' do
        before do
          sign_out :user
          sign_in :user, member
        end

        it "updates docker_image_id when Project#valid?" do
          project_params = {
            id: project.id, project: { docker_image_id: language.id } }
          patch :update, project_params

          project.reload
          project.docker_image_id.must_equal language.id
        end

        it "updates technology_ids when Project#valid?" do
          project_params = {
            id: project.id,
            project: {
              docker_image_id: language.id,
              technology_ids: [technology.id]}
          }
          patch :update, project_params

          project.reload
          project.technology_ids.must_equal [technology.id]
        end
      end

      describe "DELETE#destroy" do
        it "doesn't destroy the project if user is not the owner" do
          member = FactoryGirl.create(:user)
          project.members << member
          sign_in :user, member

          delete :destroy, { id: project.id }
          assert_response 403

          Project.count.must_equal 1
        end

        it "destroys the project if user is the owner" do
          Octokit::Client.any_instance.stubs(:remove_hook).returns(1)
          delete :destroy, { id: project.id }

          Project.count.must_equal 0
        end

        it "doesn't delete the github webhook if project wasn't destroyed" do
          Project.any_instance.stubs(:destroy).returns(false)
          Octokit::Client.any_instance.expects(:remove_hook).never
          delete :destroy, { id: project.id }
        end
      end

      describe 'POST#toggle_private' do
        describe 'when a member tries to toggle private' do
          before do
            member = FactoryGirl.create(:user)
            project.members << member
            sign_in :user, member
          end

          it 'does not allow that action' do
            post :toggle_private, id: project.id
            assert_response 403
            project.reload
            project.is_private.must_equal true
          end
        end

        describe 'when a member tries to toggle private' do
          before do
            project
            sign_in :user, owner
          end

          it 'allows the user to toggle' do
            post :toggle_private, id: project.id
            project.reload
            project.is_private.must_equal false
            flash[:notice].must_equal "Your project is now public."
          end
        end
      end
    end
  end

  describe 'when the user is not registered' do
    describe 'when the project is private' do
      describe "GET#show" do
        it "returns ok" do
          -> { get :show, id: project.id }.
           must_raise ActiveRecord::RecordNotFound
        end
      end
    end

    describe 'when the project is public' do
      before { project.update_column(:is_private, false) }

      describe "GET#show" do
        it "returns ok" do
          get :show, id: project.id
          assert_response :ok
        end
      end
    end

    describe "DELETE#destroy" do
      it "doesn't destroy the project if user is not the owner" do
        delete :destroy, { id: project.id }
        assert_response 302
        response.location.must_equal 'http://test.host/users/sign_in'
        Project.count.must_equal 1
      end
    end

    describe 'POST#toggle_private' do
      describe 'when a member tries to toggle private' do
        it 'does not allow that action' do
          post :toggle_private, id: project.id
          assert_response 302
          response.location.must_equal 'http://test.host/users/sign_in'
          project.reload
          project.is_private.must_equal true
        end
      end
    end

    describe "PATCH#update" do
      describe 'when user is the owner' do
        it "updates docker_image_id when Project#valid?" do
          project_params = {
            id: project.id, project: { docker_image_id: language.id } }
          patch :update, project_params
          assert_response 302
          response.location.must_equal 'http://test.host/users/sign_in'
        end

        it "updates technology_ids when Project#valid?" do
          project_params = {
            id: project.id,
            project: {
              docker_image_id: language.id,
              technology_ids: [technology.id]}
          }

          patch :update, project_params
          assert_response 302
          response.location.must_equal 'http://test.host/users/sign_in'
        end
      end
    end
  end
end
