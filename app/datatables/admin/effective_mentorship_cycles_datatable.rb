module Admin
  class EffectiveMentorshipCyclesDatatable < Effective::Datatable
    filters do
      scope :all
      scope :registrable
      scope :available
      scope :upcoming
      scope :past
    end

    datatable do
      order :start_at, :desc

      col :id, visible: false
      col :created_at, visible: false
      col :updated_at, visible: false

      col :title

      col :start_at, as: :date
      col :end_at, as: :date
      col :registration_start_at, as: :date
      col :registration_end_at, as: :date

      col :max_pairings_mentor, label: "Max #{mentorships_mentors_label}"
      col :max_pairings_mentee, label: "Max #{mentorships_mentees_label}"

      col :mentorship_registrations_count, label: mentorship_registrations_label
      col :mentorship_groups_count, label: mentorship_groups_label

      col :rich_text_registration_content, label: "#{mentorship_registration_label} opt-in content", visible: false

      actions_col
    end

    collection do
      Effective::MentorshipCycle.all.deep
    end
  end
end
