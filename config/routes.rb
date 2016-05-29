Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  scope '/api' do
    get 'index', controller: :import_csv
    post 'import', controller: :import_csv
    get 'trades/index'
    get 'auth/:provider/callback' => 'oauth#callback'
    post 'auth/:provider/callback' => 'oauth#callback'
    get 'logout' => 'oauth#destroy'
  end
end
