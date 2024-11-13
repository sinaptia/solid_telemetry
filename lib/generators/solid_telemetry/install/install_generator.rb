class SolidTelemetry::InstallGenerator < Rails::Generators::Base
  include Rails::Generators::Migration

  source_root File.expand_path("templates", __dir__)

  def self.next_migration_number(dirname)
    ActiveRecord::Migration.new.next_migration_number 0
  end

  def copy_migration
    migration_template "migration.rb", "db/migrate/create_solid_telemetry_tables.rb"
  end

  def copy_initializers
    template "initializer.rb", "config/initializers/solid_telemetry.rb"
    template "otel_initializer.rb", "config/initializers/opentelemetry.rb"
  end

  private

  def migration_version
    "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]"
  end
end
