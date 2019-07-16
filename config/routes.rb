Rails.application.routes.draw do
  resources :users, only: [:create, :show, :destroy] do
    resources :accounts, only: [:index, :create, :show, :destroy, :transfer] do
      get '/balance', to: 'accounts#balance'
      post '/transfer', to: 'accounts#transfer'
    end
  end
end
