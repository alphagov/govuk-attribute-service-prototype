Rails.application.routes.draw do
  get "/ping", to: "ping#show"

  namespace :oidc do
    get :user_info, to: "user_info#show"
  end

  namespace :v1 do
    resources :attributes, only: %i[show update]
    delete "/attributes/all", to: "all_attributes#destroy"

    namespace :report do
      post "/bigquery", to: "bigquery#create"
    end
  end

  get "/healthcheck", to: "healthcheck#show"
end
