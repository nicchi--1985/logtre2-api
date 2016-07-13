Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  scope '/api' do
    get 'index', controller: :import_csv
    post 'import', controller: :import_csv
    get 'trades/index'
    get 'trades/summary' => 'trades#summary'
    get 'trades/brokers' => 'trades#brokers'
    get 'products/:broker' => 'products#index'
    get 'auth/:provider/callback' => 'oauth#callback'
    post 'auth/:provider/callback' => 'oauth#callback'
    get 'logout' => 'oauth#destroy'
    get 'me' => 'users#get_current_user'
  end
end
