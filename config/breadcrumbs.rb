crumb :root do
  link "Dashboard", root_path
end

crumb :project do |project|
  link project.name, project_path(project)
  parent :root
end

crumb :new_invitation do |project|
  link "Invite user", new_project_invitation_path(project)
  parent :project, project
end

crumb :api_credentials do |project|
  link "API Credentials", api_credentials_project_path(project)
  parent :project, project
end

crumb :project_files do |project|
  link "Files", project_files_path(project)
  parent :project, project
end

crumb :tracked_branch do |project, branch|
  link branch.branch_name, project_branch_test_runs_path(project, branch)
  parent :project, project
end

crumb :test_run do |project, run|
  link "Test Run ##{run.id}", project_branch_test_run_path(project, run.tracked_branch, run)
  parent :tracked_branch , project, run.tracked_branch
end

# If you want to split your breadcrumbs configuration over multiple files, you
# can create a folder named `config/breadcrumbs` and put your configuration
# files there. All *.rb files (e.g. `frontend.rb` or `products.rb`) in that
# folder are loaded and reloaded automatically when you change them, just like
# this file (`config/breadcrumbs.rb`).
