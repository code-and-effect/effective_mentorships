module EffectiveMentorshipsHelper

  def mentorships_name_label
    et('effective_mentorships.name')
  end

  def mentorships_mentee_label
    et('effective_mentorships.mentee')
  end

  def mentorships_mentees_label
    ets('effective_mentorships.mentee')
  end

  def mentorships_mentor_label
    et('effective_mentorships.mentor')
  end

  def mentorships_mentors_label
    ets('effective_mentorships.mentor')
  end

  def mentorship_cycle_label
    et(Effective::MentorshipCycle)
  end

  def mentorship_cycles_label
    ets(Effective::MentorshipCycle)
  end

  def mentorship_group_label
    et(EffectiveMentorships.MentorshipGroup)
  end

  def mentorship_groups_label
    ets(EffectiveMentorships.MentorshipGroup)
  end

end
