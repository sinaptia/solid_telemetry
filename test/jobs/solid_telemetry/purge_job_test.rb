require "test_helper"

module SolidTelemetry
  class PurgeJobTest < ActiveJob::TestCase
    test "purges old spans" do
      assert_changes -> { Span.count } do
        perform_enqueued_jobs { PurgeJob.perform_later }
      end
    end

    test "doesn't purge spans within the retention period" do
      assert_changes -> { Span.count } do
        perform_enqueued_jobs { PurgeJob.perform_later }
      end
    end

    test "purges old events" do
      assert_changes -> { Event.count } do
        perform_enqueued_jobs { PurgeJob.perform_later }
      end
    end

    test "doesn't purge events within the retention period" do
      assert_changes -> { Event.count } do
        perform_enqueued_jobs { PurgeJob.perform_later }
      end
    end

    test "purges old metrics" do
      assert_changes -> { Metric.count } do
        perform_enqueued_jobs { PurgeJob.perform_later }
      end
    end

    test "doesn't purge metrics within the retention period" do
      assert_no_changes -> { Metric.count } do
        perform_enqueued_jobs { PurgeJob.perform_later 45.days.ago }
      end
    end
  end
end
