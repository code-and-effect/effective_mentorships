module Effective
  class MentorshipsBulkCreateGroupsJob < ApplicationJob

    def perform(id)
      bulk_group = EffectiveMentorships.MentorshipBulkGroup.find(id)
      bulk_group.with_job_status { bulk_group.create_groups! }
    end

  end
end
