Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions"
  }

  root "dashboard#index"

  resources :organizations, param: :slug, only: [:index, :new, :create, :edit, :update, :destroy]

  scope "/o/:org_slug", as: :tenant do
    get "dashboard", to: "dashboard#index", as: :dashboard
    resources :memberships, only: [:index, :create, :update, :destroy]
    resources :projects do
      resources :tasks do
        member do
          patch :move
        end
        resources :comments, only: [:create, :destroy]
      end
    end
  end

  namespace :api do
    namespace :v1 do
      resources :organizations, only: [:index, :show]
      resources :projects, only: [:index, :show, :create] do
        resources :tasks, only: [:index, :show, :create, :update]
      end
    end
  end
end