require 'test_helper'

class ProjectFileTest < ActiveSupport::TestCase
  let(:user) { FactoryGirl.create(:user, projects_limit: 1) }
  let(:project) { FactoryGirl.create(:project, user: user) }
  let(:file) do
    FactoryGirl.create(:project_file, project: project, path: "some_path")
  end

  describe "validations" do
    it "does not allow empty contents" do
      FactoryGirl.build(:project_file, contents: nil).wont_be :valid?
      FactoryGirl.build(:project_file, contents: '').wont_be :valid?
      FactoryGirl.build(:project_file, contents: 'something').must_be :valid?
    end

    it "does not allow empty path" do
      FactoryGirl.build(:project_file, path: nil).wont_be :valid?
      FactoryGirl.build(:project_file, path: '').wont_be :valid?
      FactoryGirl.build(:project_file, path: 'something').must_be :valid?
    end

    it "does not allow same path in the project scope" do
      file
      new_file =
        FactoryGirl.build(:project_file, project: project, path: "some_path")
      new_file.wont_be :valid?
      new_file.errors[:path].must_equal ["has already been taken"]
    end
  end
end
