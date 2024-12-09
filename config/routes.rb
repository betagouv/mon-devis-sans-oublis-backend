# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  # Routes are in French voluntarily, but inner code is in English.

  # Quotes

  get "profils", to: "quote_checks#profiles", as: :profiles
  match ":profile/devis/verifier",
        to: "quote_checks#new",
        via: %i[get post],
        as: :new_quote_check,
        constraints: { profile: /#{QuoteCheck::PROFILES.join('|')}/ }
  resources :quote_checks, only: %i[index show], path: "devis" do
    member do
      get "resultats_verification", to: "quote_checks#show"
      get "corriger", to: "quote_checks#edit"
      put "corriger", to: "quote_checks#update"
    end
  end

  namespace :api do
    namespace :v1 do
      resources :profiles, only: %i[index]
      resources :quote_checks, only: %i[create show]
    end
  end

  # Website static pages

  root "home#index"

  get "a_propos", to: "pages#a_propos"
  get "contact", to: "pages#contact"

  mount GoodJob::Engine => "mdso_good_job"
end
