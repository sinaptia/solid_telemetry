module SolidTelemetry
  class Span < ApplicationRecord
    has_and_belongs_to_many :exceptions, foreign_key: :solid_telemetry_span_id, association_foreign_key: :solid_telemetry_exception_id
    has_many :events, foreign_key: :solid_telemetry_span_id, dependent: :destroy
    has_many :links, foreign_key: :solid_telemetry_span_id, dependent: :destroy

    scope :traces, -> { where parent_span_id: nil }

    scope :http, -> { where "(span_attributes->>'http.method') is not null" }

    scope :http_status_code, ->(status_code) { where "(span_attributes->>'http.status_code') like ?", status_code }
    scope :successful, -> { http_status_code "2%" }
    scope :redirection, -> { http_status_code "3%" }
    scope :client_error, -> { http_status_code "4%" }
    scope :server_error, -> { http_status_code "5%" }

    scope :search, ->(query) { where "name ilike ? OR span_id ilike ? OR trace_id ilike ?", "%#{query}%", "%#{query}%", "%#{query}%" }

    def children
      Span.where parent_span_id: span_id
    end

    def total_spans
      return 1 if children.none?

      children.map(&:total_spans).reduce(&:+) + 1
    end
  end
end
