# Dashboard - the cycles we can register for
class EffectiveMentorshipsRegistrableCyclesDatatable < Effective::Datatable
  datatable do
    order :start_at, :desc

    col :title

    col :registration do |mentorship_cycle|
      mentorship_cycle.registrable_date
    end

    col :available, label: mentorships_name_label do |mentorship_cycle|
      mentorship_cycle.available_date
    end

    col :start_at, as: :date, visible: false
    col :end_at, as: :date, visible: false
    col :registration_start_at, as: :date, visible: false
    col :registration_end_at, as: :date, visible: false
    col :max_pairings_mentor, label: "Max #{mentorships_mentors_label}", visible: false
    col :max_pairings_mentee, label: "Max #{mentorships_mentees_label}", visible: false

    actions_col(actions: []) do |cycle|
      registration = current_user.mentorship_registration(mentorship_cycle: cycle)

      if registration.blank?
        dropdown_link_to('Register', effective_mentorships.new_mentorship_cycle_mentorship_registration_path(cycle))
      else
        dropdown_link_to('Show', effective_mentorships.mentorship_cycle_mentorship_registration_path(cycle, registration))
        dropdown_link_to('Edit', effective_mentorships.edit_mentorship_cycle_mentorship_registration_path(cycle, registration))
        dropdown_link_to('Delete', effective_mentorships.mentorship_cycle_mentorship_registration_path(cycle, registration), 'data-confirm': "Really delete #{registration}?", 'data-method': :delete)
      end
    end
  end

  collection do
    Effective::MentorshipCycle.where(id: current_user.registrable_mentorship_cycles)
  end
end
