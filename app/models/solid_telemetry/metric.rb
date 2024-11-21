module SolidTelemetry
  class Metric < ApplicationRecord
    scope :cpu, -> { where name: "cpu" }
    scope :memory_used, -> { where name: "memory_used" }
    scope :memory_total, -> { where name: "memory_total" }
    scope :memory_swap, -> { where name: "memory_swap" }

    def self.data_point_condition
      if defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
        "(data_points->0->>'value')::FLOAT"
      elsif defined?(ActiveRecord::ConnectionAdapters::SQLite3Adapter)
        "data_points->0->>'value'"
      elsif defined?(ActiveRecord::ConnectionAdapters::Mysql2Adapter)
        "JSON_VALUE(data_points, '$[0].value' RETURNING FLOAT)"
      end
    end
  end
end
