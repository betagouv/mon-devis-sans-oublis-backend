# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  root "home#index"

  resources :quotes, only: [] do
    collection do
      match :check, via: %i[get post], as: :check
    end
  end

  # Website static pages
  get "a_propos", to: "pages#a_propos"
  get "contact", to: "pages#contact"
end
