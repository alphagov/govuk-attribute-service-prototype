Rails.application.routes.draw do
  get "/ping", to: "ping#show"

  namespace :oidc do
    get :user_info, to: "user_info#show"
  end

  namespace :v1 do
    resources :attributes, only: %i[show update]
    post "/attributes", to: "attributes#update_many"
    delete "/attributes/all", to: "all_attributes#destroy"
  end
end
