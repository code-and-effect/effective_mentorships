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
      end_at: Time.zone.now.end_of_day,
      registration_start_at: Time.zone.now.beginning_of_day,
      registration_end_at: Time.zone.now.end_of_day
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

  def build_effective_mentorship_registration(mentorship_cycle: nil, user: nil, opt_in: true, mentees_limit: nil, category: nil, venue: nil, location: nil, mentorship_role:)
    mentorship_cycle ||= EffectiveMentorships.MentorshipCycle.first!
    user ||= build_user()

    category ||= EffectiveMentorships.MentorshipRegistration.categories.sample
    venue ||= EffectiveMentorships.MentorshipRegistration.venues.sample
    location ||= EffectiveMentorships.MentorshipRegistration.locations.sample
    mentees_limit ||= 1

    mentorship_registration = EffectiveMentorships.MentorshipRegistration.new(
      mentorship_cycle: mentorship_cycle,
      user: user,
      mentorship_role: mentorship_role,
      accept_declaration: true,
      opt_in: opt_in,
      category: category,
      venue: venue,
      location: location
    )

    user.assign_attributes(first_name: [mentorship_role, venue, location, category].join('-'))

    if mentorship_registration.mentor?
      mentorship_registration.assign_attributes(mentor_multiple_mentees_limit: mentees_limit)
    end

    mentorship_registration
  end

  def create_effective_mentorship_mentor_registration!(mentorship_cycle: nil, user: nil, opt_in: true, mentees_limit: nil, category: nil, venue: nil, location: nil)
    registration = build_effective_mentorship_registration(mentorship_cycle: mentorship_cycle, user: user, opt_in: opt_in, mentees_limit: mentees_limit, category: category, venue: venue, location: location, mentorship_role: 'mentor')
    registration.save!
    registration
  end

  def create_effective_mentorship_mentee_registration!(mentorship_cycle: nil, user: nil, opt_in: true, category: nil, venue: nil, location: nil)
    registration = build_effective_mentorship_registration(mentorship_cycle: mentorship_cycle, user: user, opt_in: opt_in, category: category, venue: venue, location: location, mentorship_role: 'mentee')
    registration.save!
    registration
  end

  def build_effective_mentorship_bulk_group(mentorship_cycle: nil)
    mentorship_cycle ||= EffectiveMentorships.MentorshipCycle.first!

    mentorship_bulk_group = EffectiveMentorships.MentorshipBulkGroup.new(mentorship_cycle: mentorship_cycle)
    mentorship_bulk_group
  end

end
