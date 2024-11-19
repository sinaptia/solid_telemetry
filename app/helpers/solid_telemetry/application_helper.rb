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
  end
end
