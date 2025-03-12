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
end
