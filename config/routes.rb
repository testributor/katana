Rails.application.routes.draw do
  use_doorkeeper

  devise_for :projects
  devise_for :users, :controllers => { :omniauth_callbacks => "callbacks",
                                       :invitations => 'users/invitations' }

  namespace :api, default: { format: 'json' } do
    namespace :v1 do
      resources :projects, only: [] do
        collection do
          get :current
        end
      end
      resources :test_runs
      resources :test_jobs, only: [:update] do
        collection do
          patch :bind_next_pending
        end
      end
    end
  end

  get 'oauth/github_callback' => 'oauth#github_callback', as: :github_callback
  post 'webhooks/github' => 'webhooks#github', as: :github_webhook

  authenticated :user do
    root to: "dashboard#index", as: :authenticated_root
  end

  unauthenticated do
    root to: "home#index"
  end

  # If you put this in the defaults(project: nil) block above it will erase
  # the "project" param from create action resulting in error.
  resources :projects, except: [:index, :edit, :update] do
    member do
      get :api_credentials
    end
    member do
      devise_scope :user do
        resources :invitations, controller: "users/invitations",
          only: [:new, :create], as: :project_invitations
      end
    end

    resources :tracked_branches, only: [:new, :create], path: :branches,
      as: :branches do
      resources :test_runs do
        member do
          post :retry
          post :create
        end
        resources :test_jobs
      end
    end

    resources :project_files, as: :files, path: :files, except: [:show, :new, :edit]
  end
  resources :project_wizard do
    member do
      get :fetch_repos
    end
  end
end
