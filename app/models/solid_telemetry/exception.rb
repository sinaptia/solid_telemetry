module SolidTelemetry
  class Exception < ApplicationRecord
    has_many :events, foreign_key: :solid_telemetry_exception_id, dependent: :destroy
    has_and_belongs_to_many :spans, foreign_key: :solid_telemetry_exception_id, association_foreign_key: :solid_telemetry_span_id

    scope :unresolved, -> { where resolved_at: nil }

    def resolve
      update resolved_at: Time.now
    end
  end
end
