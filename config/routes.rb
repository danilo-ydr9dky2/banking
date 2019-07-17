Rails.application.routes.draw do
  devise_for :users
  resources :users, only: [:create, :show, :destroy] do
    resources :accounts, only: [:index, :create, :show, :destroy, :transfer], shallow: true do
      get '/balance', to: 'accounts#balance'
      post '/transfer/:destination_account_id', to: 'accounts#transfer'
    end
  end
end
