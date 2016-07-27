class RegistrationsController < Devise::RegistrationsController

  #http://stackoverflow.com/a/15016968
  def create
    super
    AdminNotificationMailer.user_sign_up_notification(@user).deliver_later unless @user.invalid?
  end

end
