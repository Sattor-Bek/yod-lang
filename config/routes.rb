Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'pages#home'
  resources :subtitles, only: [:create, :show], param: :url_id do
    resources :translation, only: [:create, :show], param: :url_id
  end

# :result, controller:
end
