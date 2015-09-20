require 'test_helper'
 
class Users::InvitationsControllerTest < ActionController::TestCase
  describe "GET#new" do
    let(:project) { FactoryGirl.create(:project) }
    let(:user) { FactoryGirl.create(:user) }
    before { sign_in :user, user }

    it "does not allow non owners to create invitations" do
      ->{ get :new, id: project.id }.must_raise ActiveRecord::RecordNotFound
    end

    it "allows project owners to create invitations" do
      project = FactoryGirl.create(:project, user: user)
      get :new, id: project.id
      response.status.must_equal 200
      flash[:alert].must_equal nil
    end
  end

  describe "POST#create" do
    let(:project) { FactoryGirl.create(:project) }
    let(:user) { FactoryGirl.create(:user) }
    before { sign_in :user, user }

    it "does not allow non owners to create invitations" do
      ->{ post :create, project_id: project.id, user: { email: "johndoe@example.com" } }.
        must_raise ActiveRecord::RecordNotFound
      ActionMailer::Base.deliveries.must_be_empty
    end

    it "allows project owners to create invitations" do
      project = FactoryGirl.create(:project, user: user)
      user.participating_projects << project
      post :create, user: { email: "johndoe@example.com" }, id: project.id
      flash[:alert].must_equal nil
      ActionMailer::Base.deliveries.first.subject.must_equal "Invitation instructions"
    end
  end

  describe "PUT#update" do
    let(:project) { FactoryGirl.create(:project) }

    before do
      @user = User.invite!({ :email => "new_user@example.com" }, project)
      @token = @user.raw_invitation_token
    end

    it "assigns the user accepting an invitation to the inviting project" do
      @user.participating_projects.must_equal []
      put :update, user: { invitation_token: @token, password: '12345678',
                           password_confirmation: '12345678' }
      @user.reload.invitation_accepted_at.wont_be_nil
      @user.invitation_token.must_be_nil
      @user.participating_projects.must_equal [project]
      project.members.pluck(:id).sort.must_equal [@user.id, project.user_id].sort
    end
  end
end
