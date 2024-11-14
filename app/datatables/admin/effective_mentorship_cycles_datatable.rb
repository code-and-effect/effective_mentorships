module Admin
  class EffectiveMentorshipCyclesDatatable < Effective::Datatable
    datatable do
      order :start_at, :desc

      col :id, visible: false
      col :created_at, visible: false
      col :updated_at, visible: false

      col :title
      col :start_at
      col :end_at

      col :registration_start_at
      col :registration_end_at

      col :max_pairings_mentor, label: "Max #{mentorships_mentors_label}"
      col :max_pairings_mentee, label: "Max #{mentorships_mentees_label}"

      actions_col
    end

    collection do
      Effective::MentorshipCycle.all.deep
    end
  end
end
