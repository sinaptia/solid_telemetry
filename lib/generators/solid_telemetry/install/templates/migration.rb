class CreateSolidTelemetryTables < ActiveRecord::Migration<%= migration_version %>
  def change
    create_table :solid_telemetry_hosts do |t|
      t.string :name

      t.timestamps
    end

    create_table :solid_telemetry_spans do |t|
      t.string :name
      t.string :kind
      t.json :status
      t.string :parent_span_id
      t.integer :total_recorded_attributes
      t.integer :total_recorded_events
      t.integer :total_recorded_links
      t.datetime :start_timestamp
      t.datetime :end_timestamp
      t.json :span_attributes
      t.json :resource
      t.json :instrumentation_scope
      t.string :span_id
      t.string :trace_id
      t.json :trace_flags
      t.json :tracestate
      t.decimal :duration

      as_hostname = if defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
        "resource#>>'{attributes,host.name}'"
      elsif defined?(ActiveRecord::ConnectionAdapters::SQLite3Adapter)
        "resource->>'attributes'->>'host.name'"
      elsif defined?(ActiveRecord::ConnectionAdapters::Mysql2Adapter)
        "JSON_VALUE(resource, '$.attributes.\"host.name\"')"
      end

      as_http = if defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter) || defined?(ActiveRecord::ConnectionAdapters::SQLite3Adapter)
        "span_attributes->>'http.method' IS NOT NULL"
      elsif defined?(ActiveRecord::ConnectionAdapters::Mysql2Adapter)
        "span_attributes->'$.\"http.method\"' IS NOT NULL"
      end

      as_http_status_code = if defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter) || defined?(ActiveRecord::ConnectionAdapters::SQLite3Adapter)
        "span_attributes->>'http.status_code'"
      elsif defined?(ActiveRecord::ConnectionAdapters::Mysql2Adapter)
        "span_attributes->'$.\"http.status_code\"'"
      end

      t.virtual :hostname, type: :string, as: as_hostname, stored: true
      t.virtual :http, type: :boolean, as: as_http, stored: true
      t.virtual :http_status_code, type: :string, as: as_http_status_code, stored: true

      t.index :hostname
      t.index :http
      t.index :http_status_code
      t.index :name
      t.index :parent_span_id
      t.index :span_id
      t.index :trace_id
    end

    create_table :solid_telemetry_performance_items do |t|
      t.string :name
      t.decimal :p50_duration
      t.decimal :p95_duration
      t.decimal :p99_duration
      t.decimal :p100_duration
      t.integer :throughput
      t.decimal :impact_score
      t.decimal :error_rate

      t.timestamps
    end

    create_table :solid_telemetry_links do |t|
      t.references :solid_telemetry_span, null: false, foreign_key: true
      t.json :link_attributes
      t.json :span_context
    end

    create_table :solid_telemetry_metrics do |t|
      t.string :name
      t.text :description
      t.string :unit
      t.string :instrument_kind
      t.json :resource
      t.json :instrumentation_scope
      t.json :data_points
      t.string :aggregation_temporality
      t.datetime :start_time_unix_nano
      t.datetime :time_unix_nano

      as_hostname = if defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
        "resource#>>'{attributes,host.name}'"
      elsif defined?(ActiveRecord::ConnectionAdapters::SQLite3Adapter)
        "resource->>'attributes'->>'host.name'"
      elsif defined?(ActiveRecord::ConnectionAdapters::Mysql2Adapter)
        "JSON_VALUE(resource, '$.attributes.\"host.name\"')"
      end

      as_value = if defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
        "(data_points->0->>'value')::FLOAT"
      elsif defined?(ActiveRecord::ConnectionAdapters::SQLite3Adapter)
        "data_points->0->>'value'"
      elsif defined?(ActiveRecord::ConnectionAdapters::Mysql2Adapter)
        "JSON_VALUE(data_points, '$[0].value' RETURNING FLOAT)"
      end

      t.virtual :hostname, type: :string, as: as_hostname, stored: true
      t.virtual :value, type: :float, as: as_value, stored: true
    end

    create_table :solid_telemetry_exceptions do |t|
      t.string :exception_class
      t.string :message
      t.string :fingerprint
      t.datetime :resolved_at

      t.timestamps
    end

    create_table :solid_telemetry_events do |t|
      t.string :name
      t.json :event_attributes
      t.datetime :timestamp
      t.references :solid_telemetry_span, null: false, foreign_key: true
      t.references :solid_telemetry_exception, null: true, foreign_key: true
    end

    create_join_table :solid_telemetry_exceptions, :solid_telemetry_spans do |t|
      t.index :solid_telemetry_exception_id
      t.index :solid_telemetry_span_id
    end
  end
end
