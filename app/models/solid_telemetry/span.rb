module SolidTelemetry
  class Span < ApplicationRecord
    include HostScoped

    with_recursive_tree primary_key: :span_id, foreign_key: :parent_span_id, order: :start_timestamp

    has_and_belongs_to_many :exceptions, foreign_key: :solid_telemetry_span_id, association_foreign_key: :solid_telemetry_exception_id
    has_many :events, foreign_key: :solid_telemetry_span_id, dependent: :destroy
    has_many :links, foreign_key: :solid_telemetry_span_id, dependent: :destroy

    after_create :touch_performance_item, if: -> { _1.parent_span_id.blank? && ["OpenTelemetry::Instrumentation::Rack", "OpenTelemetry::Instrumentation::ActiveJob"].include?(_1.instrumentation_scope["name"]) }

    scope :http, -> { where http_condition }

    scope :http_status_code, ->(status_code) { where http_status_code_condition, status_code }
    scope :successful, -> { http_status_code "2%" }
    scope :redirection, -> { http_status_code "3%" }
    scope :client_error, -> { http_status_code "4%" }
    scope :server_error, -> { http_status_code "5%" }

    def self.http_condition
      if defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter) || defined?(ActiveRecord::ConnectionAdapters::SQLite3Adapter)
        "(span_attributes->>'http.method') IS NOT NULL"
      elsif defined?(ActiveRecord::ConnectionAdapters::Mysql2Adapter)
        "(span_attributes->'$.\"http.method\"') IS NOT NULL"
      end
    end

    def self.http_status_code_condition
      if defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter) || defined?(ActiveRecord::ConnectionAdapters::SQLite3Adapter)
        "(span_attributes->>'http.status_code') LIKE ?"
      elsif defined?(ActiveRecord::ConnectionAdapters::Mysql2Adapter)
        "(span_attributes->'$.\"http.status_code\"') LIKE ?"
      end
    end

    private

    def touch_performance_item
      PerformanceItem.find_or_create_by(name: name).touch
    end
  end
end
