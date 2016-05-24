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

    it "is invalid when keys are missing" do
      subject.project.update_column(:repository_provider, "bare_repo")
      subject.project.reload
      subject.ssh_key_private = nil
      subject.ssh_key_public = nil
      subject.wont_be :valid?
    end
  end

  describe '#ssh_key_private' do
    it 'should be automatically generated if not provided' do
      subject.ssh_key_private = nil
      subject.valid?
      subject.ssh_key_private.must_match /^-----BEGIN RSA PRIVATE KEY-----/
      subject.ssh_key_private.must_match /-----END RSA PRIVATE KEY-----$/
    end

    it "does not generate a new pair on validations if a private key is already set" do
      subject.send(:generate_ssh_keys)
      existing_key = subject.ssh_key_private
      subject.valid?
      subject.ssh_key_private.must_equal existing_key
    end

    it "does not generate a new pair when repository_provider is bare_repo" do
      subject.project.update_column(:repository_provider, "bare_repo")
      subject.project.reload
      subject.ssh_key_private = nil
      subject.ssh_key_public = nil
      subject.valid?
      subject.ssh_key_private.must_equal nil
      subject.ssh_key_public.must_equal nil
    end

    it "is invalid if the provided private key is not valid" do
      subject.ssh_key_private = '1234'
      subject.wont_be :valid?
      subject.errors[:ssh_key_private].must_equal ["is invalid or passphrase protected"]
    end
  end

  describe "#reset_ssh_key!" do
    before do
      subject.stubs(:remove_ssh_key_from_repo).returns(true)
      subject.stubs(:set_ssh_key_in_repo).returns(true)
    end

    it "creates a new pair of ssh keys and sets it" do
      old_private_key = subject.ssh_key_private
      old_public_key = subject.ssh_key_private
      subject.reset_ssh_key!
      subject.ssh_key_private.wont_equal old_private_key
      subject.ssh_key_public.wont_equal old_public_key
    end
  end
end
