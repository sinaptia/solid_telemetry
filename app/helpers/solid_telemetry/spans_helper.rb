module SolidTelemetry
  module SpansHelper
    def span_margin(span, root)
      (span.start_timestamp - root.start_timestamp).in_milliseconds * 100 / root.duration
    end

    def span_width(span, root)
      span.duration * 100 / root.duration
    end
  end
end
