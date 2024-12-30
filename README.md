# SolidTelemetry

SolidTelemetry is a database-backed [OpenTelemetry](https://opentelemetry.io/) implementation for Ruby on Rails apps.

OpenTelemetry is an observability framework and toolkit designed to manage telemetry data such as traces, metrics, and logs. It's not an observability backend. Its main objective is to generate, collect and export telemetry data. The storage and visualization of telemetry is intentionally left to other tools, like Jaeger or Prometheus.

This means that if you want to add telemetry to your app, you need a third-party tool like Jaeger and/or Prometheus. This is not always desirable, so we built SolidTelemetry to provide an OpenTelemetry backend for Ruby on Rails apps, solid-style.

By installing SolidTelemetry, you'll get [metrics](https://opentelemetry.io/docs/concepts/signals/metrics/) (unstable) and [traces](https://opentelemetry.io/docs/concepts/signals/traces/) (stable), provided by [opentelemetry-ruby](https://github.com/open-telemetry/opentelemetry-ruby), and extra features on top of traces provided by SolidTelemetry:

* Error tracking: track, debug and resolve errors from OpenTelemetry traces.
* Performance items: track and debug performance issues from OpenTelemetry traces.

Using OpenTelemetry brings a big advantage: if for any reasons SolidTelemetry falls short for your use case, your app is already instrumented to use another backend, you only need to point to your new OpenTelemetry backend.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "solid_telemetry"
```

And then execute:

```bash
$ bundle
$ rails g solid_telemetry:install
```

This will create the configuration files `config/initializer/opentelemetry.rb` and `config/initializer/solid_telemetry.rb`, and the migration that creates the necessary tables for SolidTelemetry to work.

Once you've done that, you can execute:

```bash
$ rails db:migrate
```

to create the SolidTelemetry tables.

Finally, you need to mount the engine in your `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  # ...

  mount SolidTelemetry::Engine, at: "/telemetry"
end
```

## How it works

SolidTelemetry comes with a metric exporter and a trace exporter that instead of exporting to a third party service, inserts metrics and traces into the database, respectively.

## Configuration

After installing the gem, OpenTelemetry is automatically configured in the `config/initializers/opentelemetry.rb` initializer. By default:

* all instrumentation is enabled. You can read more about instrumentation [here](https://github.com/open-telemetry/opentelemetry-ruby-contrib/tree/main/instrumentation).
* adds the hostname to the resource
* sets up the trace exporter provided by the gem, so spans are inserted into the database

You can customize the OpenTelemetry initializer the way you need. For example, the service name is set to the name of your rails app by default. You might want to set the service name to an environment variable to distinguish the web app from the active job workers. And then use that value to filter spans or metrics. Or you might want to use a subset of instrumentation libraries, or customize the resource. You can do all that in this initializer.

The `config/initializers/solid_telemetry.rb` file holds the configuration for the SolidTelemetry features, such as the interval for the agent to record metrics. See the available configuration in the initializer.

### Authentication and authorization

SolidTelemetry leaves authentication and authorization to the user. If no authentication is enforced, `/telemetry` will be available to everyone.

By default, SolidTelemetry controllers inherit from the host app's `ApplicationController`. So if you implemented authentication and authorization in your `ApplicationController` you're all set. However, if you need to change the base class of the controller (for example if you want to restrict access to admin users), you need to set the `base_controller_class`:

```ruby
SolidTelemetry.configure do |config|
  config.base_controller_class = "AdminController"
end
```

### Advanced configuration

By default, the SolidTelemetry tables are created in your app's primary database. Since SolidTelemetry collects a lot of data, you might want to use another database for it. To do so, you need to add your telemetry database in `config/database.yml`:

```yml
production:
  primary:
    <<: *default
    database: app_production
  telemetry:
    <<: *default
    database: telemetry_production
    migrations_paths: db/telemetry_migrate
```

Then, move the `XXX_create_solid_telemetry_tables.rb` migration from `db/migrate` to `db/telemetry_migrate` and add the following to your `config/environments/production.rb` file:

```ruby
config.solid_telemetry.connects_to = { database: { writing: :telemetry }}
```

## Custom instrumentation

SolidTelemetry comes with custom ActionPack instrumentation (`SolidTelemetry::Instrumentation::ActionPack`, based on `OpenTelemetry::Instrumentation::ActionPack`) that provides detailed session and request information (if applicable), to help users with debugging:

* `rack.session`
* `action_dispatch.request.parameters`

## Data retention

By default, SolidTelemetry collects all metrics and traces with no data retention policy, meaning that the amount of data can get huge over time. However, SolidTelemetry comes with a job that allows you to purge old data, `SolidTelemetry::PurgeJob`, which will:

* delete spans, events and links
* delete metrics
* delete performance items that don't have associated spans
* update performance items that have associated spans

If you're using solid_queue or other background jobs solution, you can set it as a recurring job. Otherwise, you can just run it manually from your rails console:

```ruby
SolidTelemetry::PurgeJob.perform_now 7.days.ago
```

The only argument for the job is the oldest date we want to keep. In the example above, we're keeping data from the last 7 days. If you don't pass any argument, it will default to 30 days.

## Compatibility

SolidTelemetry is compatible with Postgres version 13 and above, MySQL version 8 and above and SQLite3 version 3.34 and above due to the use of Common Table Expressions (through [with_recursive_tree](https://github.com/sinaptia/with_recursive_tree)).

SolidTelemetry depends on [active_median](https://github.com/ankane/active_median), which requires an extension to work with MySQL. Check out [active_median](https://github.com/ankane/active_median)'s instructions to set it up.

## Contributing

You can open an issue or a PR in GitHub.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
