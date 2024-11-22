module EffectiveMentorshipsTestBuilder
  def create_user!
    build_user.tap { |user| user.save! }
  end

  def build_user
    @user_index ||= 0
    @user_index += 1

    User.new(
      email: "user#{@user_index}@example.com",
      password: 'rubicon2020',
      password_confirmation: 'rubicon2020',
      first_name: 'Test',
      last_name: 'User'
    )
  end

  def create_effective_mentorship_cycle!
    build_effective_mentorship_cycle.tap { |mentorship_cycle| mentorship_cycle.save! }
  end

  def build_effective_mentorship_cycle
    mentorship_cycle = Effective::MentorshipCycle.new(
      title: 'Mentorship Cycle',
      start_at: Time.zone.now,
      end_at: Time.zone.now.end_of_day
    )

    mentorship_cycle.rich_text_registration_content = 'Registration content'
    mentorship_cycle.rich_text_group_content = 'Group content'

    mentorship_cycle
  end

  def build_effective_mentorship_group(mentorship_cycle: nil, mentor: nil, mentee: nil)
    mentorship_cycle ||= EffectiveMentorships.MentorshipCycle.first!
    mentor ||= build_user()
    mentee ||= build_user()

    mentorship_group = EffectiveMentorships.MentorshipGroup.new(
      mentorship_cycle: mentorship_cycle,
      title: "A title",
    )

    mentorship_group.mentorship_group_users.build(user: mentor, mentorship_role: 'mentor')
    mentorship_group.mentorship_group_users.build(user: mentee, mentorship_role: 'mentee')

    mentorship_group
  end

end
