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
