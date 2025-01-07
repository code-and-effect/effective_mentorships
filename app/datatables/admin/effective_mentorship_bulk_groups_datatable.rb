module Admin
  class EffectiveMentorshipBulkGroupsDatatable < Effective::Datatable
    datatable do
      order :updated_at

      col :updated_at, visible: false
      col :created_at, visible: false
      col :id, visible: false
      col :token, visible: false

      col :mentorship_cycle
      col :title

      actions_col
    end

    collection do
      EffectiveMentorships.MentorshipBulkGroup.deep.all
    end
  end
end
