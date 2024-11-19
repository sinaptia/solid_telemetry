module SolidTelemetry
  class Event < ApplicationRecord
    belongs_to :span, foreign_key: :solid_telemetry_span_id
    belongs_to :exception, optional: true, foreign_key: :solid_telemetry_exception_id

    after_create :create_exception_from_self, if: ->(event) { event.name == "exception" }

    def relative_timestamp
      (timestamp - span.start_timestamp).in_milliseconds
    end

    private

    def create_exception_from_self
      attrs = [
        event_attributes["exception.type"],
        event_attributes["exception.message"],
        event_attributes["exception.stacktrace"].split("\n").first
      ]
      fingerprint = Digest::SHA256.hexdigest attrs.join

      exception = Exception.find_or_initialize_by fingerprint: fingerprint

      exception.update(
        exception_class: event_attributes["exception.type"],
        message: event_attributes["exception.message"],
        resolved_at: nil
      )

      exception.spans << span
      exception.events << self
    end
  end
end
