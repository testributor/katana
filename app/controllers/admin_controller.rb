class AdminController < ApplicationController
  before_filter :authenticate_user!
  before_filter :authenticate_admin

  def become
    sign_in(:user, User.find(params[:id]), bypass: true) # do not update last_sign_in
    redirect_to root_url # or user_root_url
  end

  private

  def authenticate_admin
    head :unauthorized unless current_user.admin?
  end
end
