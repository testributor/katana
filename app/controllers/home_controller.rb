class HomeController < ApplicationController
  def index
    @submission = EmailSubmission.new
  end
end
