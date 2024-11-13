require "test_helper"
require "generators/solid_telemetry/install/install_generator"

module SolidTelemetry
  class SolidTelemetry::InstallGeneratorTest < Rails::Generators::TestCase
    tests SolidTelemetry::InstallGenerator
    destination Rails.root.join("tmp/generators")
    setup :prepare_destination

    test "generates a migration for the solid_telemetry tables" do
      run_generator

      assert_migration "db/migrate/create_solid_telemetry_tables.rb"
    end

    test "generates the opentelemetry initializer" do
      run_generator

      assert_file "config/initializers/opentelemetry.rb"
    end

    test "generates the solid_telemetry initializer" do
      run_generator

      assert_file "config/initializers/solid_telemetry.rb"
    end
  end
end
