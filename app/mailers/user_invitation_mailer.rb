class UserInvitationMailer < ApplicationMailer
  def new_invitation(id)
    @user_invitation = UserInvitation.find(id)
    @accept_url = accept_user_invitation_url(token: @user_invitation.token)
    mail(to: @user_invitation.email, subject: 'You are invited to a new project in testributor.com')
  end
end
