Rails.application.routes.draw do

  resources :trips, except: [:show, :index, :about, :oj, :contact], path: ''

  get '/', to: 'trips#show', as: 'show'
  get 'contact', to: 'trips#contact'
  get '/oj', to: 'trips#oj'
  get '/trips', to: 'trips#index'
  get '/about', to: 'trips#about'
  post '/refresh', to: 'trips#refresh'
  post '/select', to: 'trips#select'
  # post '/:id', to: 'trips#update'
  get '*url', to: 'trips#show'
end
