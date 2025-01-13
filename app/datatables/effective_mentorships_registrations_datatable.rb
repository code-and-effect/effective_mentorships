# Dashboard - the cycles we have registered for but aren't in a group for yet
class EffectiveMentorshipsRegistrationsDatatable < Effective::Datatable
  datatable do
    col :mentorship_cycle

    col :available, label: "Schedule" do |mentorship_registration|
      mentorship_registration.mentorship_cycle.available_date
    end

    col :opt_in

    col :mentorship_role do |mentorship_registration|
      if mentorship_registration.opt_in?
        badge(mentorship_registration.mentorship_role)
      else
        '-'
      end
    end

    actions_col
  end

  collection do
    current_user.mentorship_registrations_without_groups
  end
end
