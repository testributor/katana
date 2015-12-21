require 'test_helper'

class EmailSubmissionsControllerTest < ActionController::TestCase
  describe "#create" do
    let(:email) { 'pakallis@gmail.com' }
    it "creates EmailSubmission if valid" do
      xhr :post, :create, { email_submission: { email: email } }

      assert_response :ok
      EmailSubmission.last.email.must_equal email
    end

    it "doesn't create EmailSubmission if invalid" do
      xhr :post, :create, { email_submission: { email: 'invalid_email' } }

      assert_response :unprocessable_entity
      EmailSubmission.last.must_equal nil
    end
  end
end
