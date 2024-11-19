module SolidTelemetry
  module SpansHelper
    def span_margin(span)
      (span.start_timestamp - span.root.start_timestamp).in_milliseconds * 100 / span.root.duration
    end

    def span_width(span)
      span.duration * 100 / span.root.duration
    end
  end
end
