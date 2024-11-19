module SolidTelemetry
  class Span < ApplicationRecord
    acts_as_tree primary_key: :span_id, foreign_key: :parent_span_id

    has_and_belongs_to_many :exceptions, foreign_key: :solid_telemetry_span_id, association_foreign_key: :solid_telemetry_exception_id
    has_many :events, foreign_key: :solid_telemetry_span_id, dependent: :destroy
    has_many :links, foreign_key: :solid_telemetry_span_id, dependent: :destroy

    scope :http, -> { where "(span_attributes->>'http.method') is not null" }

    scope :http_status_code, ->(status_code) { where "(span_attributes->>'http.status_code') like ?", status_code }
    scope :successful, -> { http_status_code "2%" }
    scope :redirection, -> { http_status_code "3%" }
    scope :client_error, -> { http_status_code "4%" }
    scope :server_error, -> { http_status_code "5%" }
  end
end
