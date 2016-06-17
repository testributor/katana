class PagesController < ApplicationController
  def show
    page = params[:id]
    begin
      render action: page
    rescue ActionView::MissingTemplate
      raise ActionController::RoutingError.
        new("Page #{page.inspect} was not found")
    end
  end

  def letsencrypt
    # use your code here, not mine
    render text: ENV['LETS_ENCRYPT_RESPONSE']
  end
end
