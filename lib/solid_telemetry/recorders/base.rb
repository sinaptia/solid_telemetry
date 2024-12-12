module SolidTelemetry
  module Recorders
    class Base
      attr_reader :counter

      def record
        counter.add capture
      end
    end
  end
end
