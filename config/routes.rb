Rails.application.routes.draw do
  devise_for :admins
  devise_for :users
  root 'home#index'

  resources :products, only: [:show]
  resources :product_categories, only: [:index, :show, :new, :create, :edit, :update]

  resources :users, shallow: true do
    resources :cart_items, only: [:index, :create, :destroy]
    resources :orders, only: [:index, :show, :new, :create]
  end
end
