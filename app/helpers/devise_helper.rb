module DeviseHelper
  def devise_error_messages!
    return "" if resource.errors.empty?

    html = <<-HTML
      <div class='alert alert-danger'>
        #{resource.errors.full_messages.first}
      </div>
      </br>
    HTML

    html.html_safe
  end
end
