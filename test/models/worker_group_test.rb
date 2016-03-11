require 'test_helper'

class WorkerGroupTest < ActiveSupport::TestCase
  subject { FactoryGirl.build(:worker_group) }

  describe 'validations' do
    describe '#friendly_name' do
      it 'must be present' do
        subject.friendly_name = nil
        subject.valid?
        subject.errors.added?(:friendly_name, :blank).must_equal true

        subject.friendly_name = 'a key name'
        subject.valid?
        subject.errors.added?(:friendly_name, :blank).must_equal false
      end

      it "must be unique in the project scope" do
        FactoryGirl.create(:worker_group, project: subject.project,
                           friendly_name: "FastWorker")
        other_project_worker_name = "OtherProjectWorker"
        FactoryGirl.create(:worker_group, friendly_name: other_project_worker_name)

        subject.friendly_name = "FastWorker"
        subject.save.must_equal false
        subject.errors[:friendly_name].must_equal ["has already been taken"]
        subject.friendly_name = other_project_worker_name
        subject.save.must_equal true
      end
    end
  end

  describe '#ssh_key_private' do
    it 'should be automatically generated if not provided' do
      subject.ssh_key_private = nil
      subject.valid?
      subject.ssh_key_private.must_match /^-----BEGIN RSA PRIVATE KEY-----/
      subject.ssh_key_private.must_match /-----END RSA PRIVATE KEY-----$/
    end
  end
end
