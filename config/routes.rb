Rails.application.routes.draw do
  resources :trips, path: '' do
    get :about
    get :contact
    get :oj, to: 'trips#index'
  end

  get '/', to: 'trips#show'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
