Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'pages#home'
  # post 'pages/guest' => 'pages#guest'
  post '/pages/guest_sign_in', to: 'pages#new_guest'

  resources :subtitles, only: [:create, :show], param: :url_id do
    resources :translations, only: [:create, :show], param: :url_id
  end

# :result, controller:
end
