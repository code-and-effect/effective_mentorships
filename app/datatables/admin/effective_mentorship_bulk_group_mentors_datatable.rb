module Admin
  class EffectiveMentorshipBulkGroupMentorsDatatable < Effective::Datatable
    datatable do
      order :updated_at

      col :updated_at, visible: false
      col :created_at, visible: false
      col :id, visible: false
      col :token, visible: false

      col :to_s, label: 'User', action: true

      col :first_name, visible: false
      col :last_name, visible: false
      col :email, visible: false

      if defined?(EffectiveMemberships)
        col(:member_number, label: 'Member #', sort: false, visible: false) do |user|
          user.try(:membership).try(:number)
        end.search do |collection, term|
          memberships = Effective::Membership.where(owner_type: current_user.class.name).where('number ILIKE ?', "%#{term}%")
          collection.where(id: memberships.select('owner_id'))
        end

        col(:membership_categories, label: 'Member Category', sort: false, visible: false, search: EffectiveMemberships.Category.sorted.all) do |user|
          Array(user.try(:membership).try(:membership_categories)).each do |membership_category|
            content_tag(:div, membership_category, class: 'col-resource')
          end.join.html_safe
        end.search do |collection, term|
          memberships = Effective::Membership.where(owner_type: current_user.class.name).with_category(term)
          collection.where(id: memberships.select('owner_id'))
        end

        col(:membership_statuses, label: 'Member Status', sort: false, visible: false, search: EffectiveMemberships.Status.sorted.all) do |user|
          Array(user.try(:membership).try(:statuses)).each do |status|
            content_tag(:div, status, class: 'col-resource')
          end.join.html_safe
        end.search do |collection, term|
          memberships = Effective::Membership.where(owner_type: current_user.class.name).with_status(term)
          collection.where(id: memberships.select('owner_id'))
        end
      end

      col :mentorship_registration_role, label: 'Role', search: mentorship_roles_collection() do |user|
        registration = user.mentorship_registration(mentorship_cycle: mentorship_bulk_group.mentorship_cycle)
        mentorship_role_label(registration.mentorship_role)
      end

      col :mentorship_registration_category, label: 'Category', search: EffectiveMentorships.MentorshipRegistration.categories do |user|
        registration = user.mentorship_registration(mentorship_cycle: mentorship_bulk_group.mentorship_cycle)
        registration.category
      end

      col :mentorship_registration_venue, label: 'Venue', search: EffectiveMentorships.MentorshipRegistration.venues do |user|
        registration = user.mentorship_registration(mentorship_cycle: mentorship_bulk_group.mentorship_cycle)
        registration.venue
      end

      col :mentorship_registration_location, label: 'Location', search: EffectiveMentorships.MentorshipRegistration.locations do |user|
        registration = user.mentorship_registration(mentorship_cycle: mentorship_bulk_group.mentorship_cycle)
        registration.location
      end

      col :mentorship_mentor_multiple_mentees_limit, label: "#{mentorships_mentees_label} Limit" do |user|
        registration = user.mentorship_registration(mentorship_cycle: mentorship_bulk_group.mentorship_cycle)
        registration.mentor_multiple_mentees_limit
      end

      actions_col(only: [:show, :edit])
    end

    collection do
      users = mentorship_bulk_group.mentorship_mentors
      raise("expected a relation of effective_mentorship_users") unless users.try(:effective_mentorships_user?)

      users
    end

    def mentorship_bulk_group
      @mentorship_bulk_group ||= EffectiveMentorships.MentorshipBulkGroup.find_by_id(attributes[:mentorship_bulk_group_id])
    end

  end
end
