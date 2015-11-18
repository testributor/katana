class TestRunDecorator < ApplicationDecorator
  delegate_all

  def commit_message(options={})
    options.reverse_merge!(render_as_link: false)
    if model.commit_message.present?
      # http://stackoverflow.com/a/18134919/859387
      cm = "#{h.truncate(model.commit_message.split("\n")[0], length: 80, separator: ' ')} (##{model.commit_sha[0...7]})"
      if options[:render_as_link]
        cm = h.link_to cm, model.commit_url, title: 'See this commit on GitHub',
          target: '_blank'
      end

      cm
    else
      model.commit_sha
    end
  end
end
