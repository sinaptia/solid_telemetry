module SolidTelemetry
  module Exporters
    module ActiveRecord
      class TraceExporter
        include Exportable

        def export(spans, timeout: nil)
          return SUCCESS unless SolidTelemetry.enabled?

          Rails.logger.silence do
            Array(spans).sort_by(&:start_timestamp).each do |span_data|
              OpenTelemetry::Common::Utilities.untraced do
                start_timestamp = parse_timestamp span_data.start_timestamp
                end_timestamp = parse_timestamp span_data.end_timestamp

                parent_span_id = (span_data.parent_span_id == OpenTelemetry::Trace::INVALID_SPAN_ID) ? nil : span_data.hex_parent_span_id

                span = Span.create(
                  name: span_data.name,
                  kind: span_data.kind,
                  status: span_data.status.as_json,
                  parent_span_id: parent_span_id,
                  total_recorded_attributes: span_data.total_recorded_attributes,
                  total_recorded_events: span_data.total_recorded_events,
                  total_recorded_links: span_data.total_recorded_links,
                  start_timestamp: start_timestamp,
                  end_timestamp: end_timestamp,
                  duration: (end_timestamp - start_timestamp).in_milliseconds,
                  span_attributes: span_data.attributes.as_json,
                  resource: span_data.resource.as_json,
                  instrumentation_scope: span_data.instrumentation_scope.as_json,
                  span_id: span_data.hex_span_id,
                  trace_id: span_data.hex_trace_id,
                  trace_flags: span_data.trace_flags.as_json,
                  tracestate: span_data.tracestate.as_json
                )

                if span_data.total_recorded_links.positive?
                  span_data.links.each do |link_data|
                    span.links << Link.new(
                      link_attributes: link_data.attributes.as_json,
                      span_context: link_data.span_context.as_json.deep_transform_values! { |v|
                        if !v.is_a?(String)
                          v
                        else
                          v.is_utf8? ? v : v.unpack1("H*")
                        end
                      }
                    )
                  end
                end

                if span_data.total_recorded_events.positive?
                  span_data.events.each do |event_data|
                    span.events << Event.new(
                      name: event_data.name,
                      event_attributes: event_data.attributes.as_json,
                      timestamp: parse_timestamp(event_data.timestamp)
                    )
                  end
                end
              end
            rescue => e
              pp e.message
              pp e.backtrace
            end
          end

          SUCCESS
        end
      end
    end
  end
end
