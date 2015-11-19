module ApplicationHelper
  def brand_name
    'Testributor'
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
    Octokit.authorize_url(Octokit.client_id, scope: 'user:email,repo',
                         redirect_uri: github_callback_url)
  end

  def wizard_step_class(step)
    class_str = "current" if current_step?(step)
    class_str = "disabled" if future_step?(step)
    class_str = "done" if past_step?(step)

    class_str
  end

  def grouped_languages_options
    DockerImage.languages.group_by(&:standardized_name).
      map do |group, languages|
      [
        group, languages.map do |language|
          [language.public_name, language.id]
        end
      ]
    end
  end

  def technologies_options
    DockerImage.technologies.map do |technology|
      [technology.public_name, technology.id]
    end
  end
end
