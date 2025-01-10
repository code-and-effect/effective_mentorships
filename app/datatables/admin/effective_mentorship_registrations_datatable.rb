module Admin
  class EffectiveMentorshipRegistrationsDatatable < Effective::Datatable
    filters do
      scope :all
      scope :opt_in
      scope :opt_out
      scope :opt_in_without_groups
    end

    datatable do
      order :updated_at

      col :updated_at, visible: false
      col :created_at, visible: false
      col :id, visible: false
      col :token, visible: false

      col :mentorship_cycle
      col :user

      col :opt_in, visible: attributes[:opt_in_without_groups].blank?

      col :mentorship_role, search: mentorship_roles_collection() do |registration|
        mentorship_role_label(registration.mentorship_role)
      end

      col :category, search: EffectiveMentorships.MentorshipRegistration.categories
      col :venue, search: EffectiveMentorships.MentorshipRegistration.venues
      col :location, search: EffectiveMentorships.MentorshipRegistration.locations
      col :mentor_multiple_mentees_limit, label: "#{mentorships_mentees_label} Limit"

      col :parent, visible: false
      col :rich_text_comments, label: "Comments", visible: false

      col(:mentorship_groups, search: :string, visible: false) do |registration|
        registration.mentorship_groups.map do |mentorship_group|
          content_tag(:div, class: 'col-resource_item') do
            link_to(mentorship_group, effective_mentorships.edit_admin_mentorship_group_path(mentorship_group), target: '_blank')
          end
        end.join.html_safe
      end

      actions_col
    end

    collection do
      scope = EffectiveMentorships.MentorshipRegistration.deep.all

      if attributes[:opt_in_without_groups]
        scope = scope.opt_in.without_groups
      end

      scope
    end
  end
end
