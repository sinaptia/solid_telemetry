SolidTelemetry::Engine.routes.draw do
  resources :exceptions, only: %i[index show] do
    member do
      put :resolve
    end
  end
  resources :metrics, only: %i[index]
  resources :span_names, path: "performance", only: %i[index show]
  resources :spans, only: %i[index show]

  root to: "metrics#index"
end
