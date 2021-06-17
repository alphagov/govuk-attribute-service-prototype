Rails.application.routes.draw do
  get "/ping", to: "ping#show"

  namespace :oidc do
    get :user_info, to: "user_info#show"
  end

  namespace :v1 do
    delete "/attributes/all", to: "all_attributes#destroy"
    post "/attributes", to: "bulk_attributes#update"
    resources :attributes, only: %i[show update destroy]

    namespace :report do
      post "/bigquery", to: "bigquery#create"
    end
  end

  get "/healthcheck", to: "healthcheck#show"
end
