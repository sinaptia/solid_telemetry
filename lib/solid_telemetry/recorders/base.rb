module SolidTelemetry
  module Recorders
    class Base
      attr_reader :counter

      def attributes
        {OpenTelemetry::SemanticConventions::Resource::HOST_NAME => hostname}
      end

      def hostname
        `hostname`.chomp
      end

      def record
        counter.add capture, attributes: attributes
      end
    end
  end
end
