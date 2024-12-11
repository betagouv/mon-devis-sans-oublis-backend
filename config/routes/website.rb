# frozen_string_literal: true

Rails.application.routes.draw do
  # Website static pages

  root "home#index"

  get "a_propos", to: "pages#a_propos"
  get "contact", to: "pages#contact"
end
