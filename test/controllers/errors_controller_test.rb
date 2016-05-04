require 'test_helper'

class ErrorsControllerTest < ActionController::TestCase
  describe "GET#internal_server_error" do
    it 'returns status 500' do
      get :internal_server_error
      assert_response 500
    end
  end

  describe "GET#not_found" do
    it 'returns status 404' do
      get :not_found
      assert_response 404
    end
  end

  describe "GET#access_denied" do
    it 'returns status 403' do
      get :access_denied
      assert_response 403
    end
  end
end
