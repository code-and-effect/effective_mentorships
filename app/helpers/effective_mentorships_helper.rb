module EffectiveMentorshipsHelper

  def mentorships_name_label
    et('effective_mentorships.name')
  end

  def mentorship_cycle_label
    et(Effective::MentorshipCycle)
  end

  def mentorship_cycles_label
    ets(Effective::MentorshipCycle)
  end

  def mentorship_registration_label
    et(EffectiveMentorships.MentorshipRegistration)
  end

  def mentorship_registrations_label
    ets(EffectiveMentorships.MentorshipRegistration)
  end

  def mentorship_group_label
    et(EffectiveMentorships.MentorshipGroup)
  end

  def mentorship_groups_label
    ets(EffectiveMentorships.MentorshipGroup)
  end

  def mentorship_group_user_label
    ets(Effective::MentorshipGroupUser)
  end

  def mentorship_group_users_label
    ets(Effective::MentorshipGroupUser)
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

  def mentorship_roles_collection
    EffectiveMentorships.MentorshipRegistration.mentorship_roles.map { |role| [mentorship_role_label(role), role] }
  end

  def mentorship_role_label(role)
    case role.to_s
    when 'mentor' then et('effective_mentorships.mentor')
    when 'mentee' then et('effective_mentorships.mentee')
    when 'both' then et('effective_mentorships.both')
    else
      raise("unexpected mentorship role: #{role}")
    end
  end

  def mentorship_role_badge(mentorship_role)
    badge(mentorship_role_label(mentorship_role))
  end

end
