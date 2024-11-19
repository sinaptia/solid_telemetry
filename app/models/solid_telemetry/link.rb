module SolidTelemetry
  class Link < ApplicationRecord
    belongs_to :span, foreign_key: :solid_telemetry_span_id

    def linked_span
      @linked_span ||= Span.find_by span_id: span_context["span_id"]
    end
  end
end
