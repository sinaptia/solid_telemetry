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
  create_table "solid_telemetry_events", force: :cascade do |t|
    t.string "name"
    t.json "event_attributes"
    t.datetime "timestamp"
    t.integer "solid_telemetry_span_id", null: false
    t.integer "solid_telemetry_exception_id"
    t.index ["solid_telemetry_exception_id"], name: "index_solid_telemetry_events_on_solid_telemetry_exception_id"
    t.index ["solid_telemetry_span_id"], name: "index_solid_telemetry_events_on_solid_telemetry_span_id"
  end

  create_table "solid_telemetry_exceptions", force: :cascade do |t|
    t.string "exception_class"
    t.string "message"
    t.string "fingerprint"
    t.datetime "resolved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "solid_telemetry_exceptions_spans", id: false, force: :cascade do |t|
    t.integer "solid_telemetry_exception_id", null: false
    t.integer "solid_telemetry_span_id", null: false
    t.index ["solid_telemetry_exception_id"], name: "idx_on_solid_telemetry_exception_id_704d50818d"
    t.index ["solid_telemetry_span_id"], name: "idx_on_solid_telemetry_span_id_04b4c525f7"
  end

  create_table "solid_telemetry_links", force: :cascade do |t|
    t.integer "solid_telemetry_span_id", null: false
    t.json "link_attributes"
    t.json "span_context"
    t.index ["solid_telemetry_span_id"], name: "index_solid_telemetry_links_on_solid_telemetry_span_id"
  end

  create_table "solid_telemetry_metrics", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "unit"
    t.string "instrument_kind"
    t.json "resource"
    t.json "instrumentation_scope"
    t.json "data_points"
    t.string "aggregation_temporality"
    t.datetime "start_time_unix_nano"
    t.datetime "time_unix_nano"
  end

  create_table "solid_telemetry_spans", force: :cascade do |t|
    t.string "name"
    t.string "kind"
    t.json "status"
    t.string "parent_span_id"
    t.integer "total_recorded_attributes"
    t.integer "total_recorded_events"
    t.integer "total_recorded_links"
    t.datetime "start_timestamp"
    t.datetime "end_timestamp"
    t.json "span_attributes"
    t.json "resource"
    t.json "instrumentation_scope"
    t.string "span_id"
    t.string "trace_id"
    t.json "trace_flags"
    t.json "tracestate"
    t.decimal "duration"
  end

  add_foreign_key "solid_telemetry_events", "solid_telemetry_exceptions"
  add_foreign_key "solid_telemetry_events", "solid_telemetry_spans"
  add_foreign_key "solid_telemetry_links", "solid_telemetry_spans"
end
