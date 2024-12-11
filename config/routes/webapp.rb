# frozen_string_literal: true

Rails.application.routes.draw do
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
end
