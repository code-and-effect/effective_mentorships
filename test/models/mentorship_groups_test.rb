require 'test_helper'

class MentorshipGroupsTest < ActiveSupport::TestCase
  test 'create a valid mentorship group' do
    mentorship_group = build_effective_mentorship_group()
    assert mentorship_group.valid?
  end
end
