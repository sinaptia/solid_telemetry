module SolidTelemetry
  class SpanName < ApplicationRecord
    has_many :performance_items, foreign_key: :solid_telemetry_span_name_id
    has_many :spans, foreign_key: :solid_telemetry_span_name_id

    validates :name, presence: true, uniqueness: true
  end
end
