module SolidTelemetry
  class Metric < ApplicationRecord
    include HostScoped

    scope :cpu, -> { where name: "cpu.load" }
    scope :memory_used, -> { where name: "memory.used" }
    scope :memory_total, -> { where name: "memory.total" }
    scope :memory_swap, -> { where name: "memory.swap" }
  end
end
