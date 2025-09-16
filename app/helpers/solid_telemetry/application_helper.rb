module SolidTelemetry
  module ApplicationHelper
    def badge(color, text)
      # colors:
      # gray: bg-gray-50 text-gray-700 ring-gray-600/10
      # red: bg-red-50 text-red-700 ring-red-600/10
      # yellow: bg-yellow-50 text-yellow-700 ring-yellow-600/10
      # green: bg-green-50 text-green-700 ring-green-600/10
      # blue: bg-blue-50 text-blue-700 ring-blue-600/10
      # indigo: bg-indigo-50 text-indigo-700 ring-indigo-600/10
      # purple: bg-purple-50 text-purple-700 ring-purple-600/10
      # pink: bg-pink-50 text-pink-700 ring-pink-600/10
      content_tag :span, text, class: "inline-flex items-center rounded-md bg-#{color}-50 px-2 py-1 text-xs font-medium text-#{color}-700 ring-1 ring-inset ring-#{color}-600/10"
    end

    def has_data?(series)
      series.map { _1[:data] }.flatten.any?
    end

    def resolution_options
      {"1 minute" => 1, "10 minutes" => 10, "1 hour" => 60}
    end

    def sort_link(column, title)
      direction = (column.to_s == sort_column && sort_direction == "asc") ? "desc" : "asc"

      link_to({sort: column, direction: direction, **filter_param}, class: "space-x-2") do
        concat content_tag :span, title

        if column.to_s == sort_column
          concat image_tag("chevron-#{(sort_direction == "asc") ? "up" : "down"}.svg", class: "inline w-4")
        end
      end
    end
  end
end
