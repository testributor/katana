class CallbacksController < Devise::OmniauthCallbacksController
  def github
    @user = User.from_omniauth(request.env["omniauth.auth"])
    if @user
      sign_in_and_redirect @user
    else
      flash[:alert] = "Oops. It seems that your email is private."\
        "You can change your email settings on github or create a Testributor account."
      redirect_to :back
    end
  end
end
