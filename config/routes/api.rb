# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :profiles, only: %i[index]
      resources :quote_checks, only: %i[create show]
    end
  end
end
