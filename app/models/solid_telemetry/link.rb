module SolidTelemetry
  class Link < ApplicationRecord
    belongs_to :span, foreign_key: :solid_telemetry_span_id
  end
end
