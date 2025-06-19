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

This will create the configuration files `config/initializer/opentelemetry.rb` and `config/initializer/solid_telemetry.rb`, and the telemetry schema (`db/telemetry_schema.rb`) necessary for SolidTelemetry to work.

Calling `rails g solid_telemetry:install` will automatically add `config.solid_queue.connects_to = { database: { writing: :telemetry } }` to `config/environments/development.rb` and `config/environments/production.rb`, but the database configuration is left untouched. To configure the databases, make sure you add a `telemetry` database:

```diff
development:
+ primary:
    <<: *default
    database: app_development
+ telemetry:
+   <<: *default
+   database: telemetry_development
+   migrations_paths: db/telemetry_migrate
```

Once you've done that, you can execute:

```bash
$ rails db:prepare
```

to ensure the database is create and the schema is loaded.

The reason behind this decision is that SolidTelemetry collects a huge amount of data and we want this data separated from our application. Besides, this is now the standard with all the solid_* gems from Rails.

Finally, you need to mount the engine in your `config/routes.rb`:

```ruby
Rails.application.routes.draw do
  # ...

  mount SolidTelemetry::Engine, at: "/telemetry"
end
```

## How it works

SolidTelemetry comes with a metric exporter and a trace exporter that exports signals to ActiveRecord instead of an OTLP (OpenTelemetry Protocol) endpoint or third party service. Traces and Metrics are imported as they are sent to the exporters. Once in the database, they are used to display the metrics dashboard, the raw traces and the Performance Items and Exceptions, which are a layer on top of the aforementioned traces.

### Metrics

SolidTelemetry comes with a periodic metric reader, subclass of `OpenTelemetry::SDK::Metrics::Export::PeriodicMetricReader`, that will collect various metrics using different instrument kinds. By default, SolidTelemetry collects CPU load, total memory, used memory, swap memory, response time (P50, P95, P99), throughput (2xx, 3xx, 4xx, 5xx), and active job throughput (successful and failed jobs).

### Exceptions

Exceptions are automatically extracted from traces. When an exception occurrs in your app, one or more of the spans in its trace will have an associated event. Those events contain the exception type, message and stacktrace. Similar to commercial APMs such as Rollbar, AppSignal, etc. SolidTelemetry groups them by class name and where in your code happened.

You can inspect each occurrence of every exception, and resolve them once you think they're not gonna happen again.

### Performance items

SolidTelemetry groups traces by name (eg `PostsController#show`) and shows how they perform:

* P50
* P95
* P99
* Throughput
* Error rate
* Impact score

You should look at all the metrics to decide which Rails actions you want to optimize. However, the impact score can help you a little bit. The impact score is calculated as: `(throughput * combined duration) / 1000`. This score gives you an idea of how much time is spent on a specific action. The higher the score, the more impact it has.

You can inspect the slowest traces for a given performance item.

## Configuration

After installing the gem, OpenTelemetry is automatically configured in the `config/initializers/opentelemetry.rb` initializer. By default:

* all instrumentation is enabled. You can read more about instrumentation [here](https://github.com/open-telemetry/opentelemetry-ruby-contrib/tree/main/instrumentation).
* adds the hostname and the service name to the resource
* sets up the trace exporter provided by the gem, so spans are inserted into the database

You can customize the OpenTelemetry initializer the way you need. For example, the service name is set to `unknown_service` unless the `OTEL_SERVICE_NAME` env var is set, but you can set your own. Or you might want to use a subset of instrumentation libraries, or customize the resource. You can do all that in this initializer.

The `config/initializers/solid_telemetry.rb` file holds the configuration for the SolidTelemetry features. See the available configuration in the initializer.

### OpenTelemetry settings

You can also set most of the `OTEL_*` env vars to configure certain aspects of the OpenTelemetry SDK. For example, if you want to customize the periodic metric readers interval, you can set the `OTEL_METRIC_EXPORT_INTERVAL` env var (otherwise it'll default to 60 seconds).

Currently there's no official list of env vars used in OpenTelemetry, but you can [search the code](https://github.com/search?q=repo%3Aopen-telemetry%2Fopentelemetry-ruby%20OTEL_&type=code).

### Authentication and authorization

SolidTelemetry leaves authentication and authorization to the user. If no authentication is enforced, `/telemetry` will be available to everyone.

By default, SolidTelemetry controllers inherit from the host app's `ApplicationController`. So if you implemented authentication and authorization in your `ApplicationController` you're all set. However, if you need to change the base class of the controller (for example if you want to restrict access to admin users), you need to set the `base_controller_class`:

```ruby
SolidTelemetry.configure do |config|
  config.base_controller_class = "AdminController"
end
```

## Metrics

By default, SolidTelemetry shows 5 charts:

* CPU usage
* Memory usage
* Response time
* Throughput
* ActiveJob throughput

You can change the order, remove metrics or add custom metrics in the `config/initializers/solid_telemetry.rb` file.

### Custom metrics

In SolidTelemetry there are 2 kinds of metrics: metrics that measure something with [instruments](https://github.com/open-telemetry/opentelemetry-ruby/tree/main/metrics_sdk/lib/opentelemetry/sdk/metrics/instrument) (cpu load, memory usage, etc), and metrics that measure data from somewhere else, tipically traces (but could be your own app's data).

In both cases, you need to subclass the `SolidTelemetry::Metrics::Base` class and define a few things:

```ruby
class RandomMetric < SolidTelemetry::Metrics::Base
  name "random" # self-explanatory
  description "A random metric for demonstration purposes" # self-explanatory
  unit "things" # optional, used by opentelemetry internally, doesn't have a specific use
  instrument_kind :gauge # optional, what kind of instrument are we using to measure. don't define it if you are looking data elsewhere

  # this method will be called periodically. don't define it if you are planning to look data elsewhere
  def measure
    rand 100
  end
end
```

Then, you need to add this class to the `config/initializers/solid_telemetry.rb` file:

```ruby
SolidTelemetry.configure do |config|
  # ...
  config.metrics = {
    cpu: [SolidTelemetry::Metrics::Cpu],
    # ...
    random: [RandomMetric]
  }
end
```

The `metrics` setting must be a hash, where the key is the chart name and the value is an array of metrics that will be shown in that chart.

You can look at the [existing metrics](/lib/solid_telemetry/metrics/) for inspiration.

## Custom instrumentation

SolidTelemetry comes with custom ActionPack instrumentation (`SolidTelemetry::Instrumentation::ActionPack`, based on `OpenTelemetry::Instrumentation::ActionPack`) that provides detailed session and request information (if applicable), to help users with debugging:

* `rack.session`
* `action_dispatch.request.parameters`
* `gc.allocations`: the number of allocations between the start and end of `process_action.action_controller`
* `gc.time`: the amount of time spent on garbage collection between the start and end of `process_action.action_controller`

*Note*: `gc.*` data is bound to the current process. This means `gc.allocations` includes the objects allocated by OpenTelemetry (exporter, spans, metrics, etc.), and `gc.time` includes the time spent its garbage collection. So, when looking at the data, you should consider these factors.

## Purging old data

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

## Development

SolidTelemetry uses [tailwindcss-rails](https://github.com/rails/tailwindcss-rails) for styling. If any change is done to styling, run this command to regenerate the css:

```bash
$ bundle exec tailwindcss -i app/assets/stylesheets/solid_telemetry/application.tailwind.css -o app/assets/builds/solid_telemetry.css --minify
```

Append `-w` to that command to watch for changes.

## Contributing

You can open an issue or a PR in GitHub.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
