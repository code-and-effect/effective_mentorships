# Dashboard - the cycles we can register for
class EffectiveMentorshipsAvailableCyclesDatatable < Effective::Datatable
  datatable do
    order :start_at, :desc

    col :title

    col :registration, label: "Registration available" do |mentorship_cycle|
      mentorship_cycle.registrable_date
    end

    col :available, label: "Schedule" do |mentorship_cycle|
      mentorship_cycle.available_date
    end

    col :start_at, visible: false

    actions_col(actions: []) do |cycle|
      registration = current_user.mentorship_registration(mentorship_cycle: cycle)

      if registration.blank?
        if EffectiveResources.authorized?(self, :new, EffectiveMentorships.MentorshipRegistration)
          dropdown_link_to('Register', effective_mentorships.new_mentorship_cycle_mentorship_registration_path(cycle))
        end
      else
        if EffectiveResources.authorized?(self, :edit, registration)
          dropdown_link_to('Edit', effective_mentorships.edit_mentorship_cycle_mentorship_registration_path(cycle, registration))
        end

        if EffectiveResources.authorized?(self, :destroy, registration)
          dropdown_link_to('Delete', effective_mentorships.mentorship_cycle_mentorship_registration_path(cycle, registration), 'data-confirm': "Really delete #{registration}?", 'data-method': :delete)
        end
      end
    end
  end

  collection do
    Effective::MentorshipCycle.where(id: current_user.registrable_mentorship_cycles)
  end
end
