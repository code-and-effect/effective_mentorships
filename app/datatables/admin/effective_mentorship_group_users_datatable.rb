module Admin
  class EffectiveMentorshipGroupUsersDatatable < Effective::Datatable
    datatable do
      order :updated_at

      col :updated_at, visible: false
      col :created_at, visible: false
      col :id, visible: false

      col :mentorship_cycle
      col :mentorship_group
      col :mentorship_role
      col :user

      actions_col
    end

    collection do
      Effective::MentorshipGroupUser.deep.all
    end
  end
end
