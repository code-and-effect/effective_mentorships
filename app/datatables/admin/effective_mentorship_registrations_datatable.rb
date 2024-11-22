module Admin
  class EffectiveMentorshipRegistrationsDatatable < Effective::Datatable
    filters do
      scope :all
      scope :opt_in
      scope :opt_out
    end

    datatable do
      order :updated_at

      col :updated_at, visible: false
      col :created_at, visible: false
      col :id, visible: false
      col :token, visible: false

      col :mentorship_cycle
      col :user

      col :opt_in

      col :mentorship_role, search: mentorship_roles_collection() do |registration|
        mentorship_role_label(registration.mentorship_role)
      end

      col :category, search: EffectiveMentorships.MentorshipRegistration.categories
      col :venue, search: EffectiveMentorships.MentorshipRegistration.venues
      col :location, search: EffectiveMentorships.MentorshipRegistration.locations
      col :mentor_multiple_mentees, visible: false
      col :mentor_multiple_mentees_limit, visible: false

      col :rich_text_comments, label: "Comments", visible: false

      actions_col
    end

    collection do
      EffectiveMentorships.MentorshipRegistration.deep.all
    end
  end
end
