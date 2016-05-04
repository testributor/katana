class ErrorsController < ApplicationController
  layout "application_layout"

  def not_found
    render(status: 404)
  end

  def access_denied
    render(status: 403)
  end

  def internal_server_error
    render(status: 500)
  end
end
