class TestRunDecorator < ApplicationDecorator
  delegate_all

  # https://github.com/drapergem/draper/issues/268#issuecomment-55512283
  include Rails.application.routes.url_helpers

  def commit_message(options={})
    options.reverse_merge!(render_as_link: false)

    if model.commit_message.present?
      # http://stackoverflow.com/a/18134919/859387
      cm = h.truncate(model.commit_message.split("\n")[0], length: 80,
                      escape: false, separator: ' ')
      cm = "#{cm} (##{commit_sha[0...7]})"

      if options[:render_as_link]
        cm = h.link_to cm, commit_url, title: 'See this commit on GitHub',
          target: '_blank'
      end

      cm
    else
      model.commit_sha
    end
  end

  def commit_info
    return nil if commit_timestamp.nil? # generic repo on setup state

    author = if commit_author_email == commit_committer_email
                commit_author_name
              else
                "#{commit_author_name} (with #{commit_committer_name})"
              end
    info = <<-HTML
      #{author}
      committed
      <span title='#{l(commit_timestamp, format: :long)}'>
        #{h.time_ago_in_words(commit_timestamp)} ago
      <span>
    HTML

    info.html_safe
  end

  def commit_author
    if commit_author_email == commit_committer_email
      commit_author_name
    else
      "#{commit_author_name} (with #{commit_committer_name})"
    end
  end

  def commit_time_ago
     h.time_ago_in_words(commit_timestamp)
  end

  def decorated_commit_timestamp
    l(commit_timestamp, format: :long)
  end

  def commit_info_as_hash
    { build_url: project_test_run_url(object.project, object),
      message: commit_message,
      author: commit_author,
      time_ago: commit_time_ago,
      timestamp: decorated_commit_timestamp,
      commit_url: object.commit_url,
      source_logo: commit_source_logo,
      photo_url: photo_url }
  end

   def commit_source_logo
     h.asset_path("#{object.project.repository_provider}-logo.png")
   end

   def photo_url
     model.commit_committer_photo_url.present? ? model.commit_committer_photo_url : h.asset_path('anonymous-icon.png')
   end
end
