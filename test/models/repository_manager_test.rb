require 'test_helper'

class RepositoryManagerTest < ActiveSupport::TestCase
  let(:project) { FactoryGirl.build(:project, repository_provider: "github") }

  describe "manager" do
    it "is initialized based on project's repository_provider when GitHub" do
      subject = RepositoryManager.new(project)
      subject.manager.class.name.must_equal "GithubRepositoryManager"
    end

    it "is initialized based on project's repository_provider when Bitbucket" do
      project.repository_provider = "bitbucket"
      subject = RepositoryManager.new(project)
      subject.manager.class.name.must_equal "BitbucketRepositoryManager"
    end

    it "is initialized based on project's repository_provider when Bare repo" do
      project.repository_provider = "bare_repo"
      subject = RepositoryManager.new(project)
      subject.manager.class.name.must_equal "BareRepositoryManager"
    end

    it "raises if repository_manager is not implemented" do
      project.repository_provider = "dummy_provider"
      ->{ RepositoryManager.new(project) }.must_raise "Unknown repository provider"
    end
  end
end
