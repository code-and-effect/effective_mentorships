require 'test_helper'

class MentorshipBulkGroupTest < ActiveSupport::TestCase
  test 'bulk group' do
    mentorship_bulk_group = build_effective_mentorship_bulk_group()
    assert mentorship_bulk_group.valid?
  end

  test 'create groups with no registrations' do
    mentorship_bulk_group = build_effective_mentorship_bulk_group()
    mentorship_bulk_group.save!

    mentorship_bulk_group.create_groups!
    assert_equal 0, mentorship_bulk_group.mentorship_groups.count
  end

  test 'create groups with 5 registrations' do
    5.times { create_effective_mentorship_mentor_registration! }
    5.times { create_effective_mentorship_mentee_registration! }

    mentorship_bulk_group = build_effective_mentorship_bulk_group()
    mentorship_bulk_group.save!

    mentorship_bulk_group.create_groups!
    assert_equal 5, mentorship_bulk_group.mentorship_groups.count

    assert_equal 5, Effective::MentorshipGroup.all.count
    assert_equal 10, Effective::MentorshipGroupUser.all.count
  end

  # This test is flakey and I don't know why
  test 'create groups with venue registrations' do
    # Build mentors
    mentor1 = create_effective_mentorship_mentor_registration!(venue: 'In-person', category: 'General')
    mentor2 = create_effective_mentorship_mentor_registration!(venue: 'In-person', category: 'Industry Specific')
    mentor3 = create_effective_mentorship_mentor_registration!(venue: 'Either', category: 'General')
    mentor4 = create_effective_mentorship_mentor_registration!(venue: 'Either', category: 'Industry Specific')
    mentor5 = create_effective_mentorship_mentor_registration!(venue: 'Virtual', category: 'General')
    mentor6 = create_effective_mentorship_mentor_registration!(venue: 'Virtual', category: 'Industry Specific')

    # Build mentees
    mentee1 = create_effective_mentorship_mentee_registration!(venue: 'In-person', category: 'General')
    mentee2 = create_effective_mentorship_mentee_registration!(venue: 'In-person', category: 'Industry Specific')
    mentee3 = create_effective_mentorship_mentee_registration!(venue: 'Either', category: 'General')
    mentee4 = create_effective_mentorship_mentee_registration!(venue: 'Either', category: 'Industry Specific')
    mentee5 = create_effective_mentorship_mentee_registration!(venue: 'Virtual', category: 'General')
    mentee6 = create_effective_mentorship_mentee_registration!(venue: 'Virtual', category: 'Industry Specific')

    mentorship_bulk_group = build_effective_mentorship_bulk_group()
    mentorship_bulk_group.save!

    mentorship_bulk_group.create_groups!
    assert_equal 6, mentorship_bulk_group.mentorship_groups.count

    assert_equal 6, Effective::MentorshipGroup.all.count
    assert_equal 12, Effective::MentorshipGroupUser.all.count

    assert mentorship_bulk_group.mentorship_groups.find { |group| group.mentors.first == mentor1.user && group.mentees.first == mentee1.user }.present?
    assert mentorship_bulk_group.mentorship_groups.find { |group| group.mentors.first == mentor2.user && group.mentees.first == mentee2.user }.present?
    assert mentorship_bulk_group.mentorship_groups.find { |group| group.mentors.first == mentor3.user && group.mentees.first == mentee3.user }.present?
    assert mentorship_bulk_group.mentorship_groups.find { |group| group.mentors.first == mentor4.user && group.mentees.first == mentee4.user }.present?
    assert mentorship_bulk_group.mentorship_groups.find { |group| group.mentors.first == mentor5.user && group.mentees.first == mentee5.user }.present?
    assert mentorship_bulk_group.mentorship_groups.find { |group| group.mentors.first == mentor6.user && group.mentees.first == mentee6.user }.present?
  end

end
