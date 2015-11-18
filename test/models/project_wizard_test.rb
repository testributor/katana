require 'test_helper'

class ProjectWizardTest < ActiveSupport::TestCase
  describe "validations" do
    subject { FactoryGirl.create(:project_wizard) }

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
end
