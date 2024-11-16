module Admin
  class EffectiveMentorshipRegistrationsDatatable < Effective::Datatable
    filters do
      scope :all
      scope :mentors
      scope :mentees
      scope :both
    end

    datatable do
      order :updated_at

      col :updated_at, visible: false
      col :created_at, visible: false
      col :id, visible: false
      col :token, visible: false

      col :mentorship_cycle
      col :user

      col :mentorship_role, search: mentorship_roles_collection() do |registration|
        mentorship_role_label(registration.mentorship_role)
      end

      col :rich_text_comments, label: "Comments"

      actions_col
    end

    collection do
      EffectiveMentorships.MentorshipRegistration.deep.all
    end
  end
end
