class ProjectWizardController < WizardController
  REDIRECT_MESSAGES = {
    add_project: "You need to select a repository first",
    add_branches: "You need to select a branch first",
    configure_testributor: "You need to configure testributor.yml",
    select_technologies: "You need to select technologies first",
  }
  steps *ProjectWizard::ORDERED_STEPS
  before_action :fetch_project_wizard

  def show
    # Inform user that he has reached project limit
    if !current_user.can_create_new_project?
      flash[:alert] = I18n.t(
        'activerecord.errors.models.
        project.attributes.base.project_limit_reached')

      redirect_to root_path and return
    end

    if (step_to_show = @project_wizard.step_to_show) != step && step_to_show &&
      ProjectWizard::ORDERED_STEPS.index(step_to_show).to_i <
        ProjectWizard::ORDERED_STEPS.index(step).to_i

      flash[:alert] = REDIRECT_MESSAGES[step_to_show]
      redirect_to project_wizard_path(step_to_show) and return
    end

    case step
    when :add_project
      @repos = @project_wizard.fetch_repos
    when :add_branches
      redirect_if_blank_client and return
      @branches = @project_wizard.fetch_branches
    when :configure_testributor
    when :select_technologies
    end

    render_wizard
  end

  def update
    case step
    when :add_project
      @project_wizard.assign_attributes({repo_name: params[:repo_name]})
    when :add_branches
      @project_wizard.branch_names = params[:branch_names]
    when :configure_testributor
      @project_wizard.assign_attributes({
        testributor_yml: params[:testributor_yml]})
    when :select_technologies
      @project_wizard.selected_technologies = params[:selected_technologies]
    end

    if @project_wizard.save(context: step)
      if step == ProjectWizard::ORDERED_STEPS.last
        @project_wizard.to_project && @project_wizard.create_branches &&
          @project_wizard.destroy
      end

      redirect_to next_wizard_path
    else
      # TODO : where do we show this?
      flash[:alert] = @project_wizard.errors.full_messages.to_sentence
      redirect_to :back
    end
  end

  private

  def fetch_project_wizard
    @project_wizard =
      ProjectWizard.find_or_create_by(user_id: current_user.id)
  end

  def redirect_if_blank_client
    if current_user.github_client.blank?
      redirect_to project_wizard_path(:add_project)
    end
  end
end
