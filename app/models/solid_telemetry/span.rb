module SolidTelemetry
  class Span < ApplicationRecord
    include HostScoped

    with_recursive_tree primary_key: :span_id, foreign_key: :parent_span_id, order: :start_timestamp

    has_and_belongs_to_many :exceptions, foreign_key: :solid_telemetry_span_id, association_foreign_key: :solid_telemetry_exception_id
    has_many :events, foreign_key: :solid_telemetry_span_id, dependent: :destroy
    has_many :links, foreign_key: :solid_telemetry_span_id, dependent: :destroy

    after_create :touch_performance_item, if: -> { _1.root? && ["OpenTelemetry::Instrumentation::Rack", "OpenTelemetry::Instrumentation::ActiveJob"].include?(_1.instrumentation_scope["name"]) }

    scope :active_job, -> { where instrumentation_scope_name: "OpenTelemetry::Instrumentation::ActiveJob" }
    scope :rack, -> { where instrumentation_scope_name: "OpenTelemetry::Instrumentation::Rack" }

    scope :successful, -> { where "http_status_code LIKE ?", "2%" }
    scope :redirection, -> { where "http_status_code LIKE ?", "3%" }
    scope :client_error, -> { where "http_status_code LIKE ?", "4%" }
    scope :server_error, -> { where "http_status_code LIKE ?", "5%" }

    private

    def touch_performance_item
      PerformanceItem.find_or_create_by(name: name).touch
    end
  end
end
