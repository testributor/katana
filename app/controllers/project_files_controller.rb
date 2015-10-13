class ProjectFilesController < DashboardController
  include Controllers::EnsureProject

  def index
    @project_files = current_project.project_files.order("created_at DESC")
  end

  def create
    file = current_project.project_files.create(file_params)
    if file.persisted?
      flash[:notice] = "File created"
    else
      flash[:alert] = file.errors.full_messages.join(', ')
    end

    redirect_to :back
  end

  def destroy
    file = current_project.project_files.find(params[:id])
    if file.destroy
      flash[:notice] = "File destroyed"
    else
      flash[:alert] = file.errors.full_messages.join(', ')
    end

    redirect_to :back
  end

  def update
    file = current_project.project_files.find(params[:id])
    if file.update(file_params)
      flash[:notice] = "File updated"
    else
      flash[:alert] = file.errors.full_messages.join(', ')
    end

    redirect_to :back
  end

  private

  def file_params
    params.require(:project_file).permit(:path, :contents)
  end
end
