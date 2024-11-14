require 'test_helper'

class MentorshipCyclesTest < ActiveSupport::TestCase

  test 'create a valid cycle' do
    mentorship_cycle = build_effective_mentorship_cycle()
    assert mentorship_cycle.valid?
  end

  test 'latest cycle is present' do
    latest_cycle = Effective::MentorshipCycle.latest_cycle # From seeds
    assert latest_cycle.present?
  end

end
