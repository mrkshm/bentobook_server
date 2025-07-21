Rails.application.routes.draw do
  resources :configurations, only: [] do
    get :ios_v1, on: :collection
  end

  # API routes
  

  # Public area (SEO, shareable)
  scope "(:locale)", locale: /#{I18n.available_locales.join('|')}/ do
    root "pages#home"
    post "/subscribe", to: "subscriptions#create", as: :subscribe
    get "/pages/terms", to: "pages#terms", as: :terms
    get "/pages/privacy", to: "pages#privacy", as: :pages_privacy

    # Devise routes for session management
    devise_for :users, only: [:sessions, :confirmations], controllers: {
      sessions: "users/sessions",
      confirmations: "users/confirmations"
    }
  end

  # Authenticated area - no locale segment
  authenticate :user do
    # Devise routes without locale
    devise_for :users, skip: [:sessions, :confirmations], controllers: {
      # registrations: "users/registrations",
      # passwords: "users/passwords"
    }

    # Restaurant routes
    resources :restaurants do
      collection do
        get "tagged/:tag", action: :index, as: :tagged
        post "new/confirm", to: "restaurants#new_confirm"
      end

      resource :cuisine_selection, only: [ :edit, :update ], controller: "restaurants/cuisine_selections"

      resources :images, only: [ :new, :create, :destroy ] do
        collection do
          get :edit, to: "restaurants#edit_images", as: :edit
        end
      end
      resource :notes, only: [ :edit, :update ], module: :restaurants
      resource :tags, only: [ :edit, :update ], module: :restaurants
      resource :rating, only: [ :edit, :update ], module: :restaurants
      resource :price_level, only: [ :edit, :update ], module: :restaurants
      resource :business_status, only: [:edit, :update], controller: 'restaurants/business_status'
    end

    resources :visits do
      resources :images, only: [ :new, :create, :destroy ] do
        collection do
          get :edit, to: "visits#edit_images", as: :edit
        end
      end
      resource :notes, only: [ :show, :edit, :update ], module: :visits
      resource :title, only: [ :show, :edit, :update ], module: :visits
      resource :rating, only: [ :show, :edit, :update ], module: :visits
      resource :date, only: [ :show, :edit, :update ], module: :visits
      resource :contacts, only: [ :show, :edit, :create, :destroy ], module: :visits do
        get :search, on: :collection
      end
      resource :price_paid, only: [ :show, :edit, :update, :destroy ], module: :visits
    end

    resources :contacts

    resources :images, only: [ :destroy ] do
      collection do
        delete :bulk_destroy
      end
    end

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
    resource :profile, only: [ :show, :edit, :update ] do
      member do
        patch :update_theme
        delete :avatar, action: :delete_avatar
      end
      resource :language, only: [ :edit, :update ], module: :profiles
    end
    get "/profiles/search", to: "profiles#search", as: :search_profiles, format: :html
    get "/organizations/search", to: "organizations#search", as: :search_organizations, format: :html

    get "/debug/test_s3/:blob_id", to: "debug#test_s3"

    get "home/dashboard", as: :home_dashboard
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
