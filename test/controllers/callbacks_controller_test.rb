require 'test_helper'

class CallbacksControllerTest < ActionController::TestCase
  describe "#github" do
    describe "when email is private" do
      before { User.stubs(:from_omniauth).returns(nil) }

      it "redirects to sign up" do
        get :github
        response.status.must_equal 302
        flash[:alert].must_equal 'Oops. It seems that your email is private.You can change your email settings on github or create a Testributor account.'
      end
    end
  end
end
