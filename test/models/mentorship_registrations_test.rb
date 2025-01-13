require 'test_helper'

class MentorshipRegistrationsTest < ActiveSupport::TestCase
  test 'create a valid mentorship registration' do
    mentorship_registration = build_effective_mentorship_registration(mentorship_role: 'mentee')
    assert mentorship_registration.valid?
  end

  test 'mentor mentorship registration' do
    mentorship_registration = create_effective_mentorship_mentor_registration!()
    assert mentorship_registration.valid?
    assert mentorship_registration.mentor?
  end

  test 'mentee mentorship registration' do
    mentorship_registration = create_effective_mentorship_mentee_registration!()
    assert mentorship_registration.valid?
    assert mentorship_registration.mentee?
  end
end
