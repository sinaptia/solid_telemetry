module SolidTelemetry
  class Span < ApplicationRecord
    include HostScoped

    with_recursive_tree primary_key: :span_id, foreign_key: :parent_span_id, order: :start_timestamp

    belongs_to :span_name, foreign_key: :solid_telemetry_span_name_id
    has_and_belongs_to_many :exceptions, foreign_key: :solid_telemetry_span_id, association_foreign_key: :solid_telemetry_exception_id
    has_many :events, foreign_key: :solid_telemetry_span_id, dependent: :destroy
    has_many :links, foreign_key: :solid_telemetry_span_id, dependent: :destroy

    scope :active_job, -> { where instrumentation_scope_name: "OpenTelemetry::Instrumentation::ActiveJob" }
    scope :rack, -> { where instrumentation_scope_name: "OpenTelemetry::Instrumentation::Rack" }

    scope :successful, -> { where http_status_code: 200..299 }
    scope :redirection, -> { where http_status_code: 300..399 }
    scope :client_error, -> { where http_status_code: 400..499 }
    scope :server_error, -> { where http_status_code: 500..599 }

    delegate :name, to: :span_name
  end
end
