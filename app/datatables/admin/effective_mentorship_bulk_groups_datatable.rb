module Admin
  class EffectiveMentorshipBulkGroupsDatatable < Effective::Datatable
    datatable do
      order :updated_at

      col :updated_at, visible: false
      col :created_at, visible: false
      col :id, visible: false
      col :token, visible: false

      col :to_s, label: 'Title'

      col :mentorship_cycle
      col :last_completed_step

      col :mentorship_groups_count, label: "#{mentorship_groups_label} count"
      col :mentorship_groups, label: "#{mentorship_groups_label}", search: :string, visible: false
      col :email_form_skip, label: "Skip email"

      col :job_status, visible: false
      col :job_started_at, visible: false
      col :job_ended_at, visible: false
      col :job_error, visible: false

      actions_col
    end

    collection do
      EffectiveMentorships.MentorshipBulkGroup.deep.all
    end
  end
end
