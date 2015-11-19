class ProjectParticipationsController < DashboardController
  include Controllers::EnsureProject

  def index
    authorize! :manage, current_project

    @participations = current_project.project_participations.
      where("user_id != ?", current_user.id).includes(:user)

    @pending_invitations = [] # TODO
  end

  def destroy
    authorize! :manage, current_project

    participation = current_project.project_participations.
      where("user_id != ?", current_user.id).find(params[:id])

    if participation.destroy
      flash[:notice] = "User is no longer a member of this project"
    else
      flash[:alert] = participation.errors.full_messages.to_sentence
    end

    redirect_to :back
  end
end

