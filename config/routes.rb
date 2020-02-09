Rails.application.routes.draw do
  get 'forums/new'
  get 'forums/create'
  get 'forums/edit'
  get 'forums/update'
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'pages#home'
  # post 'pages/guest' => 'pages#guest'
  post '/pages/guest_sign_in', to: 'pages#new_guest'
  resources :forums, only: [:index, :create, :show, :edit, :update] do
    resources :pots
  end

  resources :subtitles, only: [:index, :create, :show, :eidt, :update], param: :url_id do
    resources :translations, only: [:index, :create, :show], param: :url_id
  end

# :result, controller:
end
