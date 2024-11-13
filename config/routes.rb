SolidTelemetry::Engine.routes.draw do
  resources :exceptions, only: %i[index show] do
    member do
      put :resolve
    end
  end
  resources :metrics, only: %i[index]
  resources :spans, only: %i[index show]

  root to: "metrics#index"
end
