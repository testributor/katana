module ApplicationHelper
  def brand_name
    'Testributor'
  end

  def flash_messages(map = {})
    # overridable flash type to bootstrap alert class mapping
    # http://getbootstrap.com/components/#alerts
    map = Hash.new { |hash, key| hash[key.to_s] = key.to_s }
    map = map.merge({
      'error' => 'danger',
      'alert' => 'warning',
      'notice' => 'success'
    }).merge(map)
    if flash.present?
      flash.map do |type, msg|
        # keys starting with underscore are not meant for display,
        # as we use them to pass values between requests
        unless type.to_s.starts_with?('_')
          content_tag(:div, class: "alert alert-dismissable alert-#{map[type.to_s]}") do
            content_tag(:button, :class => 'close', :type => 'button',
                        'aria-hidden' => 'true', 'data-dismiss' => 'alert') do
              content_tag(:i, '', :class => 'icon-cancel-circle')
            end +
            content_tag(:p, msg)
          end
        end
      end.join.html_safe
    end
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
