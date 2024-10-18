Rails.application.routes.draw do
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

    resource :profile, only: [:show, :edit, :update] do
      post 'change_locale', on: :collection
    end

    get "pages/home"
    root "pages#home"
  end

  # Routes outside of the locale scope
  get "up" => "rails/health#show", as: :rails_health_check
end
