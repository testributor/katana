# https://github.com/plataformatec/devise/wiki/How-To:-Redirect-to-a-specific-page-when-the-user-can-not-be-authenticated
class CustomFailure < Devise::FailureApp
  def redirect_url
    # If comming from sign_in page (as in the case of wrong password)
    # or there is no setting to override the redirect url, use the default
    # method.
    if request.referer == new_user_session_url || !ENV["UNAUTHORIZED_REDIRECT_URL"]
      super
    else
      ENV["UNAUTHORIZED_REDIRECT_URL"]
    end
  end

  # You need to override respond to eliminate recall
  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end
end
