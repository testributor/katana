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
end
