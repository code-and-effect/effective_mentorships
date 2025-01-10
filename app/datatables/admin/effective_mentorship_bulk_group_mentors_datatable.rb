module Admin
  class EffectiveMentorshipBulkGroupMentorsDatatable < Effective::Datatable
    datatable do
      order :updated_at

      col :updated_at, visible: false
      col :created_at, visible: false
      col :id, visible: false
      col :token, visible: false

      col :user
      col 'user.first_name', visible: false
      col 'user.last_name', visible: false
      col 'user.email', visible: false

      if defined?(EffectiveMemberships)
        col(:member_number, label: 'Member #', sort: false, visible: false) do |registration|
        registration.user.try(:membership).try(:number)
        end.search do |collection, term|
          memberships = Effective::Membership.where(owner_type: current_user.class.name).where('number ILIKE ?', "%#{term}%")
          collection.where(user_id: memberships.select('owner_id'))
        end

        col(:membership_categories, label: 'Member Category', sort: false, visible: false, search: EffectiveMemberships.Category.sorted.all) do |registration|
          Array(registration.user.try(:membership).try(:membership_categories)).each do |membership_category|
            content_tag(:div, membership_category, class: 'col-resource')
          end.join.html_safe
        end.search do |collection, term|
          memberships = Effective::Membership.where(owner_type: current_user.class.name).with_category(term)
          collection.where(user_id: memberships.select('owner_id'))
        end

        col(:membership_statuses, label: 'Member Status', sort: false, visible: false, search: EffectiveMemberships.Status.sorted.all) do |registration|
          Array(registration.user.try(:membership).try(:statuses)).each do |status|
            content_tag(:div, status, class: 'col-resource')
          end.join.html_safe
        end.search do |collection, term|
          memberships = Effective::Membership.where(owner_type: current_user.class.name).with_status(term)
          collection.where(user_id: memberships.select('owner_id'))
        end
      end

      col :mentorship_role, label: 'Role', search: mentorship_roles_collection() do |registration|
        mentorship_role_label(registration.mentorship_role)
      end

      col :category, search: EffectiveMentorships.MentorshipRegistration.categories
      col :venue, search: EffectiveMentorships.MentorshipRegistration.venues
      col :location, search: EffectiveMentorships.MentorshipRegistration.locations
      col :mentor_multiple_mentees_limit, label: "#{mentorships_mentees_label} Limit" 

      actions_col(only: [:show, :edit])
    end

    collection do
      registrations = mentorship_bulk_group.mentors_mentorship_registrations
      raise("expected a relation of registrations") unless registrations.klass.try(:effective_mentorships_registration?)

      registrations.joins(:user)
    end

    def mentorship_bulk_group
      @mentorship_bulk_group ||= EffectiveMentorships.MentorshipBulkGroup.find_by_id(attributes[:mentorship_bulk_group_id])
    end
  end
end
