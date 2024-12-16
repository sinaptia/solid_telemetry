# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2024_11_13_021446) do
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
