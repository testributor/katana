module ApplicationHelper
  def brand_name
    'Testributor'
  end

  def branch_cta(status)
    case status
    when TestStatus::PENDING, TestStatus::RUNNING
      button_text = "Cancel"
    else
      button_text = "Retry"
    end

    if button_text
      button_tag button_text, class: 'btn btn-primary retry'
    end
  end

  def controller_and_action
    "#{controller_path.split("/").join(' ')} #{action_name.gsub('_','-')}"
  end

  def page_data_attrs
    {
      "js-class" => controller_path.camelize.gsub("::", "."),
      "js-method" => action_name.camelize(:lower)
    }
  end

  def github_oauth_authorize_url
    Octokit.authorize_url(Octokit.client_id, scope: 'user:email,repo')
  end

  # we will be using this url for the api in order to avoid buying our
  # own ssl certificate. Also in order to create an OauthApplication the
  # redirect_uri must be https. There is a validation for that.
  def heroku_url
    'https://testributor.herokuapp.com'
  end
end
