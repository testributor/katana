require 'test_helper'

class DockerImageTest < ActiveSupport::TestCase
  describe "validations" do
    subject { FactoryGirl.create(:docker_image) }
    it "validates existence of standardized_name" do
      subject.standardized_name = nil
      subject.wont_be :valid?
      subject.errors[:standardized_name].must_equal ["can't be blank"]
    end
  end
end
