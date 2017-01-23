Rails.application.routes.draw do

  resources :trips, except: [:show, :index, :about, :oj, :contact], path: ''

  get '/', to: 'trips#show', as: 'show'
  get 'contact', to: 'trips#contact'
  get '/oj', to: 'trips#oj'
  get '/trips', to: 'trips#index'
  get '/about', to: 'trips#about'
  post '/refresh', to: 'trips#refresh'
  post '/select', to: 'trips#select'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
