require 'test_helper'

class MentorshipCyclesTest < ActiveSupport::TestCase
  test 'create a valid cycle' do
    mentorship_cycle = build_effective_mentorship_cycle()
    assert mentorship_cycle.valid?
  end
end
