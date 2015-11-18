class ProjectFilesController < DashboardController
  include Controllers::EnsureProject

  def index
    @testributor_yml = current_project.
      project_files.find_by_path(TestRun::JOBS_YML_PATH)
    redirect_to project_file_path(
      current_project, @testributor_yml) and return
  end

  def new
    @project_files = current_project.project_files
    @file = ProjectFile.new
    render :show
  end

  def create
    file = current_project.project_files.create(file_params)
    if file.persisted?
      flash[:notice] = "#{file.path} created"
    else
      flash[:alert] = file.errors.full_messages.join(', ')
    end

    redirect_to :back
  end

  def show
    @file = current_project.project_files.find(params[:id])
    @project_files = current_project.project_files
  end

  def destroy
    file = current_project.project_files.find(params[:id])
    file_name = file.path
    if file.destroy
      flash[:notice] = "#{file_name} was deleted"
    else
      flash[:alert] = file.errors.full_messages.join(', ')
    end

    redirect_to project_file_path(
      current_project, current_project.project_files.first)
  end

  def update
    file = current_project.project_files.find(params[:id])
    if file.update(file_params)
      flash[:notice] = "#{file.path} updated successfully."
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
