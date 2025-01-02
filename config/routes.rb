Rails.application.routes.draw do
  # API routes
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      # Session management
      post "/sessions", to: "sessions#create"
      get "/sessions", to: "sessions#index"
      delete "/session", to: "sessions#destroy_current"  # Logout current session
      delete "/sessions/:id", to: "sessions#destroy"     # Logout specific session
      delete "/sessions", to: "sessions#destroy_all"     # Logout all other sessions
      post "/refresh_token", to: "sessions#refresh"

      # Registration
      post "/register", to: "registrations#create"

      # Protected resources
      get "/profile", to: "profiles#show"
      patch "/profile", to: "profiles#update"
      patch "/profile/avatar", to: "profiles#update_avatar"
      put "/profile", to: "profiles#update"
      get "/profiles/search", to: "profiles#search"
      patch "/profile/locale", to: "profiles#change_locale"

      resources :restaurants do
        member do
          post :add_tag
          delete :remove_tag
        end
        resources :images, only: [ :create, :destroy ]
      end

      resources :contacts, only: [ :index, :show, :create, :update, :destroy ] do
        collection do
          get :search
        end
      end
      resources :visits, only: [ :index, :show, :create, :update, :destroy ] do
        resources :images, only: [ :create, :destroy ]
      end
      resources :images, only: [ :destroy ]

      # Share management
      resources :shares, only: [ :index, :destroy ] do
        member do
          post :accept
          post :decline
        end
        collection do
          post :accept_all
          post :decline_all
        end
      end

      resources :lists do
        member do
          get :export
        end
        resources :restaurants, only: [ :create, :destroy ], controller: "list_restaurants"
        resources :shares, only: [ :index, :create ]
      end

      post "/usernames/verify", to: "usernames#verify"
    end
  end

  # Web routes
  scope "(:locale)", locale: /fr/ do
    # Devise routes
    devise_for :users,
      controllers: {
        confirmations: "users/confirmations"
      },
      constraints: { format: /html|native/ }

    # Restaurant routes
    resources :restaurants do
      member do
        post :add_tag
        delete :remove_tag
      end
      collection do
        get "tagged/:tag", action: :index, as: :tagged
      end
      resources :images, only: [ :create, :destroy ]
    end

    resources :visits do
      resources :images, only: [ :destroy ]
    end

    resources :contacts

    resources :images, only: [ :destroy ]

    # Share routes
    resources :shares, only: [ :create ] do
      member do
        patch :accept
        patch :decline
      end
    end

    # List routes
    resources :lists do
      member do
        get :share
        delete :remove_share
        post :accept_share
        delete :decline_share
        get :export
        post :export
      end
      resources :list_restaurants do
        collection do
          get :edit
          post :import_all
        end
        member do
          post :import
        end
      end
    end

    # Profile routes
    resource :profile, only: [ :show, :edit, :update ]
    get "/profiles/search", to: "profiles#search", as: :search_profiles, format: :html

    # Static pages
    get "/pages/terms", to: "pages#terms", as: :terms
    get "/pages/home", to: "pages#home", as: :pages_home

    root to: "pages#home"
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  post "/profile/change_locale", to: "profiles#change_locale", as: :change_locale_profile
end
