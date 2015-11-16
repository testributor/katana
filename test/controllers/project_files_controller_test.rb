require 'test_helper'

class ProjectFilesControllerTest < ActionController::TestCase
  let(:project) { FactoryGirl.create(:project) }
  let(:user) { project.user }

  before do
    project
    sign_in :user, user
    request.env["HTTP_REFERER"] = "previous_path"
  end

  describe "GET#index" do
    it "prevents not logged users" do
      sign_out :user
      get :index, project_id: project.id
      response.status.must_equal 302
      response.redirect_url.must_match /users\/sign_in/
    end

    it "allows logged users" do
      get :index, project_id: project.id
      assert_response :success
    end

    it "returns files for the specified project" do
      files = [
        project.project_files.create(path: "one", contents: "one contents"),
        project.project_files.create(path: "two", contents: "two contents") ]

      get :index, project_id: project.id
      assert_response :success
    end
  end

  describe "POST#create" do
    let(:params) do
      { path: "config/database.yml",
        contents: "database info" }
    end

    it "creates the files with the specified params" do
      old_count = ProjectFile.count
      post :create, project_id: project.id, project_file: params
      flash[:alert].must_be :blank?
      ProjectFile.count.must_equal old_count + 1
      new_file = ProjectFile.last
      new_file.path.must_equal 'config/database.yml'
      new_file.contents.must_equal 'database info'
    end
  end

  describe "DELETE#destroy" do
    subject { FactoryGirl.create(:project_file, project: project) }
    before { subject }

    it "destroys the specified file" do
      old_count = ProjectFile.count
      delete :destroy, project_id: project.id, id: subject.id
      ProjectFile.count.must_equal old_count - 1
      ProjectFile.find_by(id: subject.id).must_be :nil?
    end

    it "won't destroy other project files" do
      other_project_file = FactoryGirl.create(:project_file)

      old_count = ProjectFile.count
      ->{ delete :destroy, project_id: project.id, id: other_project_file.id }.
        must_raise ActiveRecord::RecordNotFound
      ProjectFile.count.must_equal old_count
      ProjectFile.find_by(id: other_project_file.id).
        must_equal other_project_file
    end
  end

  describe "PUT#update" do
    subject { FactoryGirl.create(:project_file, project: project) }

    it "updates the specified record" do
      put :update, project_id: project.id, id: subject.id,
        project_file: { path: "the new path", contents: "the new contents" }
      flash[:alert].must_be :blank?

      subject.reload.path.must_equal 'the new path'
      subject.contents.must_equal 'the new contents'
    end
  end
end
