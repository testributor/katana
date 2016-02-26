class UserInvitationMailer < ApplicationMailer
  def new_invitation(id)
    @user_invitation = UserInvitation.find(id)
    @project = Project.find(@user_invitation.project_id)
    @accept_url = accept_user_invitation_url(token: @user_invitation.token)
    mail(to: @user_invitation.email,
         reply_to: @project.user.email,
         subject: "You have been invited to the Testributor project: #{@project.name}.")
  end
end
