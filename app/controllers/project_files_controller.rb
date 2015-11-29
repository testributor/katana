class ProjectFilesController < DashboardController
  include Controllers::EnsureProject

  def index
    testributor_yml = current_project.
      project_files.find_by_path(ProjectFile::JOBS_YML_PATH)
    redirect_to project_file_path(
      current_project, testributor_yml) and return
  end

  def new
    @project_files = sorted_project_files
    @file = ProjectFile.new
    @docs = docs

    render :show
  end

  def create
    file = current_project.project_files.create(file_params)
    if file.persisted?
      flash[:notice] = "#{file.path} created"
    else
      flash[:alert] = file.errors.messages.values.join(', ')
    end

    redirect_to :back
  end

  def show
    @file = current_project.project_files.find(params[:id])
    @project_files = sorted_project_files
    @docs = docs
  end

  def destroy
    file = current_project.project_files.find(params[:id])
    file_name = file.path
    if file.destroy
      flash[:notice] = "#{file_name} was deleted"
    else
      flash[:alert] = file.errors.messages.values.join(', ')
    end

    redirect_to project_files_path(current_project)
  end

  def update
    file = current_project.project_files.find(params[:id])
    if file.update(file_params)
      flash[:notice] = "#{file.path} updated successfully."
    else
      flash[:alert] = file.errors.messages.values.join(', ')
    end

    redirect_to :back
  end

  private
  def sorted_project_files
    current_project.project_files.sort_by do |f|
      case f.path
      when ProjectFile::JOBS_YML_PATH
        0
      when ProjectFile::BUILD_COMMANDS_PATH
        1
      else
        2
      end
    end
  end

  def docs
    docs = {}
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML,
      fenced_code_blocks: true, disable_indented_code_blocks: true)

    current_project.technologies.map do |t|
      if t.docker_compose_data["documentation"].present?
        docs[t.public_name] =
          markdown.render(t.docker_compose_data["documentation"])
      end
    end
    if current_project.docker_image.docker_compose_data["documentation"].present?
      docs[current_project.docker_image.public_name] = markdown.render(
        current_project.docker_image.docker_compose_data["documentation"])
    end

    docs
  end

  def file_params
    params.require(:project_file).permit(:path, :contents)
  end
end
