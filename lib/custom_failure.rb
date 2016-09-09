# https://github.com/plataformatec/devise/wiki/How-To:-Redirect-to-a-specific-page-when-the-user-can-not-be-authenticated
class CustomFailure < Devise::FailureApp
  def redirect_url
    ENV["UNAUTHORIZED_REDIRECT_URL"] || new_user_session_path
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
