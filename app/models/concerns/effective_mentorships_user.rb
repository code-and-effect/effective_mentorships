# EffectiveMentorshipsUser
#
# Mark your user model with effective_mentorship_user to get a few helpers
# And user specific point required scores

module EffectiveMentorshipsUser
  extend ActiveSupport::Concern

  module Base
    def effective_mentorships_user
      include ::EffectiveMentorshipsUser
    end
  end

  module ClassMethods
    def effective_mentorships_user?; true; end
  end

  included do
    # App Scoped
    has_many :mentorship_groups, -> { order(:mentorship_cycle_id) }, inverse_of: :user, dependent: :destroy
    accepts_nested_attributes_for :mentorship_groups, allow_destroy: true

    has_many :mentorship_registrations, -> { order(:mentorship_cycle_id) }, inverse_of: :user, dependent: :destroy
    accepts_nested_attributes_for :mentorship_registrations, allow_destroy: true

    scope :deep_effective_mentorships_user, -> { all }
  end

  # Find
  def mentorship_group(mentorship_cycle:)
    raise('expected an MentorshipCycle') unless mentorship_cycle.class.respond_to?(:effective_mentorships_mentorship_cycle?)
    mentorship_groups.find { |mentorship_group| mentorship_group.mentorship_cycle_id == mentorship_cycle.id }
  end

  # Find or build
  def build_mentorship_group(mentorship_cycle:)
    raise('expected an MentorshipCycle') unless mentorship_cycle.class.respond_to?(:effective_mentorships_mentorship_cycle?)
    mentorship_group(mentorship_cycle: mentorship_cycle) || mentorship_groups.build(mentorship_cycle: mentorship_cycle)
  end

  # Find
  def mentorship_registration(mentorship_cycle:)
    raise('expected an MentorshipCycle') unless mentorship_cycle.class.respond_to?(:effective_mentorships_mentorship_cycle?)
    mentorship_registrations.find { |mentorship_registration| mentorship_registration.mentorship_cycle_id == mentorship_cycle.id }
  end

  # Find or build
  def build_mentorship_registration(mentorship_cycle:)
    raise('expected an MentorshipCycle') unless mentorship_cycle.class.respond_to?(:effective_mentorships_mentorship_cycle?)
    mentorship_registration(mentorship_cycle: mentorship_cycle) || mentorship_registrations.build(mentorship_cycle: mentorship_cycle)
  end

end
