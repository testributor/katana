require 'test_helper'

class SignUpFeatureTest < Capybara::Rails::TestCase
  let(:user) { FactoryGirl.create(:user)}

  describe "sign up page" do
    describe "when entering valid data" do
      before do
        visit new_user_registration_path
        fill_in 'user[email]', :with => 'spyros@testributor.com'
        fill_in 'user[password]', :with => '12345678'
        fill_in 'user[password_confirmation]', :with => '12345678'
        click_button 'Sign up'
      end

      it 'asks for e-mail confirmation' do
        page.current_url.must_equal 'http://www.example.com/'
        ActionMailer::Base.deliveries.select { |m| m.subject.match(/Confirmation/) }.
          wont_be :empty?
      end
    end

    describe "when entering invalid data" do
      before do
        visit new_user_registration_path
        fill_in 'user[email]', :with => user.email
        fill_in 'user[password]', :with => '123456'
        fill_in 'user[password_confirmation]', :with => '123456'
        click_button 'Sign up'
      end

      it 'displays appropriate error message' do
        page.must_have_selector('#error_explanation',
          text: "2 errors prohibited this user from being saved: "\
                "Email has already been takenPassword is too short (minimum is 8 characters)")
        ActionMailer::Base.deliveries.select { |m| m.subject.match(/Confirmation/) }.
          must_be :empty?
      end
    end
  end
end
