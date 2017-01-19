Rails.application.routes.draw do
  # resources :trips, path: '' do
  #   get :about, to: 'trips#about'
  #   get :contact
  #   get :oj, to: 'trips#index'
  # end

  get '/', to: 'trips#show'
  get 'contact', to: 'trips#contact'
  get '/oj', to: 'trips#oj'
  get '/trips', to: 'trips#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
