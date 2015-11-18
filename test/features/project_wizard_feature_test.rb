require 'test_helper'

class ProjectWizardFeatureTest < Capybara::Rails::TestCase
  let(:user) { FactoryGirl.create(:user) }
  let(:repo_name) { 'ispyropoulos/katana' }
  let(:language) do
    FactoryGirl.create(:docker_image, :language, public_name: 'Ruby 2.0')
  end
  let(:language2) do
    FactoryGirl.create(:docker_image, :language, public_name: 'Ruby 2.3')
  end
  let(:technology) { FactoryGirl.create(:docker_image) }

  before do
    language
    language2
    technology
    login_as user, scope: :user
  end

  it "user can't click on disabled(not-completed) steps", js: true do
    visit root_path
    VCR.use_cassette 'repos'  do
      VCR.use_cassette 'github_client' do
        find('aside').click_on 'Add a project'
        page.must_have_content repo_name
      end
    end

    click_on "Select branches"

    page.wont_have_content "You need to select a repository first"
    page.must_have_content "Select a repository"
  end

  it "creates a project with correct attributes after successful completion",
    js: true do

    visit root_path

    VCR.use_cassette 'repos'  do
      VCR.use_cassette 'github_client' do
        find('aside').click_on 'Add a project'
        page.must_have_content repo_name
      end
    end

    VCR.use_cassette 'github_client' do
      VCR.use_cassette 'branches' do
        click_on repo_name
        check 'aws'
        # Proceed to 'Configure Testributor'
        click_on 'Next'
      end
    end

    # Proceed to 'Select technologies'
    click_on 'Next'

    select technology.public_name
    select language2.public_name
    click_on 'Create project'

    project = Project.last
    project.docker_image_id.must_equal language2.id
    project.technologies.must_equal [technology]
    project.tracked_branches.
      map(&:branch_name).must_equal ['aws', 'master']
    project.repository_provider.must_equal 'github'
    project.repository_name.must_equal 'katana'
    project.repository_owner.must_equal 'ispyropoulos'
    testributor_file = project.project_files.first
    testributor_file.path.must_equal 'testributor.yml'
    page.wont_have_content "Please upgrade your plan"
  end
end
