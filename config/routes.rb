Rails.application.routes.draw do
  get "/ping", to: "ping#show"

  namespace :v1 do
    resources :attributes, only: %i[show update]
  end
end
