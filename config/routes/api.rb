# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :profiles, only: %i[index]
      resources :quote_checks, only: %i[create show] do
        collection do
          get :metadata
        end

        resources :feedbacks, only: %i[create], controller: "quote_check_feedbacks"
        resources :quote_check_validation_error_details,
                  path: "error_details",
                  as: :validation_error_details,
                  only: %i[] do
          resources :feedbacks, only: %i[create], controller: "quote_check_feedbacks"
        end
      end
      resources :stats, only: %i[index]
    end
  end

  mount Rswag::Api::Engine => "/api-docs"
  mount Rswag::Ui::Engine => "/api-docs"
end
