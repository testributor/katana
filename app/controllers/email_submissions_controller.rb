class EmailSubmissionsController < ApplicationController
  def create
    return unless request.xhr?
    @submission = EmailSubmission.new(email_submission_params)
    if @submission.save
      success_message =
        "Thanks for submitting your e-mail. You will hear from us soon!"
      render json: success_message, status: :ok
    else
      render json: @submission.errors.full_messages.first,
        status: :unprocessable_entity
    end
  end

  private

  def email_submission_params
    params.require(:email_submission).permit(:email)
  end
end
