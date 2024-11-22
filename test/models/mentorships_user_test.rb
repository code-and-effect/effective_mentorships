require 'test_helper'

class MentorshipsUserTest < ActiveSupport::TestCase
  test 'create a valid user' do
    user = build_user()
    assert user.valid?
  end

  test 'user mentorship group' do
    mentorship_cycle = EffectiveMentorships.MentorshipCycle.first!
    user = build_user()

    mentorship_group = user.build_mentorship_group(mentorship_cycle: mentorship_cycle)
    assert mentorship_group.present?
    assert_equal mentorship_cycle, mentorship_group.mentorship_cycle
  end

  test 'user mentorship registration' do
    mentorship_cycle = EffectiveMentorships.MentorshipCycle.first!
    user = build_user()

    mentorship_registration = user.build_mentorship_registration(mentorship_cycle: mentorship_cycle)
    assert mentorship_registration.present?
    assert_equal mentorship_cycle, mentorship_registration.mentorship_cycle
  end

end
