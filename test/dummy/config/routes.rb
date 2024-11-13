Rails.application.routes.draw do
  mount SolidTelemetry::Engine, at: "/telemetry"
end
