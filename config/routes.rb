# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  # Routes are in French voluntarily, but inner code is in English.

  # Quotes

  get "profils", to: "quotes#profiles", as: :profiles
  resources :quotes, only: [], path: "" do
    collection do
      match ":profile/devis/verifier",
            to: "quotes#check",
            via: %i[get post],
            as: :check,
            constraints: { profile: /#{QuotesController::PROFILES.join('|')}/ }
    end
  end

  # Website static pages

  root "home#index"

  get "a_propos", to: "pages#a_propos"
  get "contact", to: "pages#contact"
end
