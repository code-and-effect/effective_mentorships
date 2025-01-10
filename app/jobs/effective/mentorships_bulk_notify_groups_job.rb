module Effective
  class MentorshipsBulkNotifyGroupsJob < ApplicationJob

    def perform(id)
      bulk_group = EffectiveMentorships.MentorshipBulkGroup.find(id)
      bulk_group.with_job_status { bulk_group.notify_groups! }
    end

  end
end
