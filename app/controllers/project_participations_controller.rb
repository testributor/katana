class ProjectParticipationsController < DashboardController
  include Controllers::EnsureProject

  def index
    @participations = current_project.project_participations.includes(:user)
    @invitations = current_project.user_invitations.pending.includes(:user)
  end

  def destroy
    participation = current_project.project_participations.find(params[:id])

    authorize! :destroy, participation

    if participation.destroy
      if participation.user == current_user
        flash[:notice] =
          "You are no longer a member of #{participation.project.name} project"
        redirect_to authenticated_root_path
      else
        flash[:notice] = "User is no longer a member of this project"
        redirect_to :back
      end
    else
      flash[:alert] = participation.errors.full_messages.to_sentence
      redirect_to :back
    end
  end
end

