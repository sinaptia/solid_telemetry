require "test_helper"
require "generators/solid_telemetry/install/install_generator"

module SolidTelemetry
  class SolidTelemetry::InstallGeneratorTest < Rails::Generators::TestCase
    tests SolidTelemetry::InstallGenerator
    destination Rails.root.join("tmp/generators")
    setup :prepare_destination

    setup do
      FileUtils.mkdir_p File.join(destination_root, "config/environments")

      %w[development production].each do |env|
        FileUtils.cp Rails.root.join("config/environments/#{env}.rb"), File.join(destination_root, "config/environments/#{env}.rb")
      end
    end

    test "generates telemetry schema" do
      run_generator

      assert_file "db/telemetry_schema.rb"
    end

    test "generates the opentelemetry initializer" do
      run_generator

      assert_file "config/initializers/opentelemetry.rb"
    end

    test "generates the solid_telemetry initializer" do
      run_generator

      assert_file "config/initializers/solid_telemetry.rb"
    end

    test "configures the development database" do
      run_generator

      assert_file "config/environments/development.rb" do |content|
        assert_match(/config\.solid_telemetry\.connects_to = { database: { writing: :telemetry } }/, content)
      end
    end

    test "configures the production database" do
      run_generator

      assert_file "config/environments/production.rb" do |content|
        assert_match(/config\.solid_telemetry\.connects_to = { database: { writing: :telemetry } }/, content)
      end
    end
  end
end
