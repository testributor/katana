Rails.application.routes.draw do
  use_doorkeeper

  devise_for :users, :controllers => { :invitations => 'users/invitations' }
  devise_for :projects

  namespace :api, default: { format: 'json' } do
    namespace :v1 do
      resources :projects, only: [] do
        collection do
          get :current
        end
      end
      resources :test_jobs
      resources :test_job_files, only: [:update] do
        collection do
          patch :bind_next_pending
        end
      end
    end
  end

  get 'dashboard' => 'dashboard#show', as: :dashboard
  get 'oauth/github_callback' => 'oauth#github_callback'
  post 'webhooks/github' => 'webhooks#github', as: :github_webhook

  root 'home#index'
  # If you put this in the defaults(project: nil) block above it will erase
  # the "project" param from create action resulting in error.
  resources :projects, except: [:index, :edit, :update] do
    member do
      devise_scope :user do
        resources :invitations, controller: "users/invitations",
          only: [:new, :create], as: :project_invitations
      end
    end

    resources :tracked_branches, only: [:new, :create], path: :branches,
      as: :branches do
      resources :test_jobs do
        resources :test_job_files
      end
    end

    resources :project_files, as: :files, path: :files, except: [:show, :new, :edit]
  end
end
