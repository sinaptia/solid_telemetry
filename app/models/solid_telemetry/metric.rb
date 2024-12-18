module SolidTelemetry
  class Metric < ApplicationRecord
    include HostScoped

    scope :cpu, -> { where name: "cpu" }
    scope :memory_used, -> { where name: "memory_used" }
    scope :memory_total, -> { where name: "memory_total" }
    scope :memory_swap, -> { where name: "memory_swap" }
  end
end
