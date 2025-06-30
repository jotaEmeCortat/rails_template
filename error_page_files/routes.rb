Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  #root "pages#index"

  # Test routes for error simulation (development only)
  if Rails.env.development?
    get "/force_404", to: "errors#error_page", defaults: { code: "404" }
    get "/force_500", to: "errors#error_page", defaults: { code: "500" }
    get "/force_422", to: "errors#error_page", defaults: { code: "422" }
  end

  # Add your application routes here:


  # IMPORTANT: Custom error pages MUST be LAST
  # This catch-all route should be at the very end to avoid conflicts
  match "/:code", to: "errors#error_page", via: :all,
    constraints: { code: /(400|404|406|422|500)/ }
end
