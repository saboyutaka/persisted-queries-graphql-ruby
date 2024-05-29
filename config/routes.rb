Rails.application.routes.draw do

  get "up" => "rails/health#show", as: :rails_health_check

  # root "posts#index"

  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end

  get "/graphql", to: "graphql#execute"
  post "/graphql", to: "graphql#execute"
end
