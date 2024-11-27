module SolidTelemetry
  module Sortable
    extend ActiveSupport::Concern

    included do
      helper_method :sort_column, :sort_direction
    end

    private

    def default_sort_column
      raise NotImplementedError
    end

    def default_sort_direction
      "desc"
    end

    def sort_column
      klass = "SolidTelemetry::#{controller_name.singularize.classify}".constantize
      klass.column_names.include?(params[:sort]) ? params[:sort] : default_sort_column
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : default_sort_direction
    end
  end
end
