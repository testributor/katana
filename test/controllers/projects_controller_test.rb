require 'test_helper'

class ProjectsControllerTest < ActionController::TestCase
  let(:project) { FactoryGirl.create(:project) }
  let(:owner) { project.user }
  let(:language) { FactoryGirl.create(:docker_image, :language) }
  let(:technology) { FactoryGirl.create(:docker_image) }
  before do
    request.env["HTTP_REFERER"] = "previous_path"
    sign_in :user, owner
  end

  describe "PATCH#update" do
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
end
