module SolidTelemetry
  module HostScoped
    extend ActiveSupport::Concern

    included do
      scope :by_host, ->(hostname) { where HostScoped.hostname_condition, hostname }
    end

    def self.hostname_condition
      if defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
        "resource#>>'{attributes,host.name}' = ?"
      elsif defined?(ActiveRecord::ConnectionAdapters::SQLite3Adapter)
        "resource->>'attributes'->>'host.name' = ?"
      elsif defined?(ActiveRecord::ConnectionAdapters::Mysql2Adapter)
        "JSON_VALUE(resource, '$.attributes.\"host.name\"') = ?"
      end
    end
  end
end
