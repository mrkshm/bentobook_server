Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # Set up a constraint for all locales, including default
  scope "(:locale)", locale: /fr/ do
    devise_for :users
    
    resources :restaurants do
      member do
        post 'add_tag'
        delete 'remove_tag'
      end
      collection do
        get 'tagged/:tag', to: 'restaurants#index', as: :tagged
      end
    end

    resources :visits do
      resources :images, only: [:destroy]
    end

    resources :contacts

    resource :profile, only: [:show, :edit, :update] do
      post 'change_locale', on: :collection
    end

    get "pages/home"
    root "pages#home"
  end

  # Routes outside of the locale scope
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      devise_for :users, controllers: {
          sessions: 'api/v1/sessions',
          registrations: 'api/v1/registrations'
        }, defaults: { format: :json }
      resource :profile, only: [:show, :update]
      resources :contacts, only: [:index, :show, :create, :update, :destroy]
      resources :visits, only: [:index, :show, :create, :update, :destroy] do
        resources :images, only: [:destroy]
      end
      resources :images, only: [:destroy]
      resources :restaurants do
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
