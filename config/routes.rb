Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  scope '/api' do
    get 'index', controller: :import_csv
    post 'import', controller: :import_csv
    get 'trades/index'
    get 'trades/summary' => 'trades#summary'
    get 'trades/productSummary' => 'trades#productSummary'
    get 'trades/brokers' => 'trades#brokers'
    get 'trades/:broker/:product' => 'trades#chart_data'
    get 'trades/analytics' => 'trades#analytics'
    get 'products/:broker' => 'products#index'
    get 'chart_data/nikkei' => 'chart_data#nikkei'
    get 'auth/:provider/callback' => 'oauth#callback'
    post 'auth/:provider/callback' => 'oauth#callback'
    get 'logout' => 'oauth#destroy'
    get 'me' => 'users#get_current_user'
  end
end
