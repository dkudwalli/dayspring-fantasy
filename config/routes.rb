Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "dashboard#index"

  resource :session, only: %i[new create destroy]
  resource :registration, only: %i[new create]
  resource :prediction_history, only: :show
  resources :password_resets, only: %i[new create edit update], param: :token

  resources :leaderboards, only: :index
  resources :predictions, only: :create

  namespace :admin do
    root "matches#index"
    resources :activity_logs, only: :index
    resources :prediction_submissions, only: :index
    resources :matches, only: %i[index new create edit update] do
      collection do
        post :import
      end

      member do
        patch :archive
        patch :restore
      end

      resources :questions, except: %i[index show destroy] do
        member do
          patch :archive
          patch :restore
        end

        resources :options, only: :destroy, controller: "question_options"
      end
    end
  end
end
