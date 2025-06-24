class SolidTelemetry::InstallGenerator < Rails::Generators::Base
  source_root File.expand_path("templates", __dir__)

  def copy_files
    template "config/initializers/opentelemetry.rb"
    template "config/initializers/solid_telemetry.rb"
    template "db/telemetry_schema.rb"
  end

  def configure_database
    %w[development production].each do |env|
      pathname = Pathname(destination_root).join("config/environments/#{env}.rb")

      gsub_file pathname, /^end\n/, "\n  config.solid_telemetry.connects_to = { database: { writing: :telemetry } }\nend\n"
    end
  end

  private

  def schema_version
    "#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}"
  end

  def virtual_hostname
    if defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
      "resource#>>'{attributes,host.name}'"
    elsif defined?(ActiveRecord::ConnectionAdapters::SQLite3Adapter)
      "resource->>'attributes'->>'host.name'"
    elsif defined?(ActiveRecord::ConnectionAdapters::Mysql2Adapter)
      "JSON_VALUE(resource, '$.attributes.\\\"host.name\\\"')"
    end
  end

  def virtual_http_status_code
    if defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter) || defined?(ActiveRecord::ConnectionAdapters::SQLite3Adapter)
      "span_attributes->>'http.status_code'"
    elsif defined?(ActiveRecord::ConnectionAdapters::Mysql2Adapter)
      "span_attributes->'$.\\\"http.status_code\\\"'"
    end
  end

  def virtual_instrumentation_scope_name
    if defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter) || defined?(ActiveRecord::ConnectionAdapters::SQLite3Adapter)
      "instrumentation_scope->>'name'"
    elsif defined?(ActiveRecord::ConnectionAdapters::Mysql2Adapter)
      "instrumentation_scope->'$.\\\"name\\\"'"
    end
  end

  def virtual_value
    if defined?(ActiveRecord::ConnectionAdapters::PostgreSQLAdapter)
      "(data_points->0->>'value')::FLOAT"
    elsif defined?(ActiveRecord::ConnectionAdapters::SQLite3Adapter)
      "data_points->0->>'value'"
    elsif defined?(ActiveRecord::ConnectionAdapters::Mysql2Adapter)
      "JSON_VALUE(data_points, '$[0].value' RETURNING FLOAT)"
    end
  end
end
