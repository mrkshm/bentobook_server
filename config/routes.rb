Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # This MUST be before the locale scope
  post "/profile/change_locale", to: "profiles#change_locale", as: :change_locale_profile

  # Set up a constraint for all locales, including default
  scope "(:locale)", locale: /fr/ do
    devise_for :users, controllers: {
      confirmations: 'users/confirmations'
    }
    
    resources :restaurants do
      member do
        post 'add_tag'
        delete 'remove_tag'
      end
      collection do
        get 'tagged/:tag', to: 'restaurants#index', as: :tagged
      end
      resources :images, only: [:create, :destroy]
    end

    resources :visits do
      resources :images, only: [:destroy]
    end

    resources :contacts

    resources :images, only: [:destroy]

    resources :shares, only: [] do
      member do
        patch :accept
        patch :decline
      end
    end

    resources :lists do
      member do
        get 'export', to: 'lists#export'
        post 'export', to: 'lists#export'
        get :share
        delete 'remove_share', to: 'lists#remove_share', as: :remove_share
        post 'accept_share', to: 'lists#accept_share'
        delete 'decline_share', to: 'lists#decline_share'
      end
      resources :list_restaurants, only: [:new, :create, :index] do
        collection do
          get :edit
          delete :destroy
        end
      end
    end

    resources :shares, only: [:create] do
      member do
        patch :accept
        patch :reject
      end
    end

    resource :profile, only: [:show, :edit, :update]

    resources :profiles, only: [] do
      collection do
        get :search, defaults: { format: :html }
      end
    end

    get "pages/terms", as: :terms
    get "pages/home"

    root "pages#home"
  end

  # Routes outside of the locale scope
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      devise_for :users, controllers: {
          sessions: 'api/v1/sessions',
          registrations: 'api/v1/registrations',
        }, defaults: { format: :json }
      resource :profile, only: [:show, :update]
      resources :contacts, only: [:index, :show, :create, :update, :destroy]
      resources :visits, only: [:index, :show, :create, :update, :destroy] do
        resources :images, only: [:create, :destroy]
      end
      resources :images, only: [:destroy]
      resources :restaurants do
        resources :images, only: [:create, :destroy]
        member do
          post "add_tag"
          delete "remove_tag"
        end
        collection do
          get 'tagged/:tag', to: 'restaurants#index', as: :tagged
        end
      end
    end
  end


end
