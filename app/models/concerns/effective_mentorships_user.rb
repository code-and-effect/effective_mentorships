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
    # Effective Scoped
    has_many :mentorship_group_users, -> { order(:mentorship_cycle_id).order(:id) }, class_name: 'Effective::MentorshipGroupUser', inverse_of: :user, dependent: :destroy

    # App Scoped
    has_many :mentorship_registrations, -> { order(:mentorship_cycle_id).order(:id) }, inverse_of: :user, dependent: :destroy
    accepts_nested_attributes_for :mentorship_registrations, allow_destroy: true

    has_many :mentorship_groups, through: :mentorship_group_users

    scope :deep_effective_mentorships_user, -> { all }

    scope :mentorships_opted_in, -> (mentorship_cycle) {
      raise('expected an EffectiveMentorships.MentorshipCycle') unless mentorship_cycle.kind_of?(Effective::MentorshipCycle)

      opted_in = EffectiveMentorships.MentorshipRegistration.opt_in.where(mentorship_cycle: mentorship_cycle)
      where(id: opted_in.select(:user_id))
    }

    scope :mentorships_opted_out, -> (mentorship_cycle) {
      raise('expected an EffectiveMentorships.MentorshipCycle') unless mentorship_cycle.kind_of?(Effective::MentorshipCycle)

      opted_out = EffectiveMentorships.MentorshipRegistration.opt_out.where(mentorship_cycle: mentorship_cycle)
      where(id: opted_out.select(:user_id))
    }

    scope :mentorships_opted_in_mentors, -> (mentorship_cycle) {
      raise('expected an EffectiveMentorships.MentorshipCycle') unless mentorship_cycle.kind_of?(Effective::MentorshipCycle)

      opted_in_mentors = EffectiveMentorships.MentorshipRegistration.opt_in.mentors.where(mentorship_cycle: mentorship_cycle)
      where(id: opted_in_mentors.select(:user_id))
    }

    scope :mentorships_opted_in_mentees, -> (mentorship_cycle) {
      raise('expected an EffectiveMentorships.MentorshipCycle') unless mentorship_cycle.kind_of?(Effective::MentorshipCycle)

      opted_in_mentees = EffectiveMentorships.MentorshipRegistration.opt_in.mentees.where(mentorship_cycle: mentorship_cycle)
      where(id: opted_in_mentees.select(:user_id))
    }

  end

  # Used for the dashboard datatables. Which cycles can we register for?
  def registrable_mentorship_cycles
    Effective::MentorshipCycle.registrable
      .where.not(id: mentorship_group_users.select(:mentorship_cycle_id))
      .where.not(id: mentorship_registrations.select(:mentorship_cycle_id))
  end

  def mentorship_registrations_without_groups
    mentorship_registrations.where.not(mentorship_cycle_id: mentorship_group_users.select(:mentorship_cycle_id))
  end

  # Find
  def mentorship_group(mentorship_cycle:)
    raise('expected an MentorshipCycle') unless mentorship_cycle.class.respond_to?(:effective_mentorships_cycle?)
    mentorship_groups.find { |mentorship_group| mentorship_group.mentorship_cycle_id == mentorship_cycle.id }
  end

  # Find or build
  def build_mentorship_group(mentorship_cycle:)
    raise('expected an MentorshipCycle') unless mentorship_cycle.class.respond_to?(:effective_mentorships_cycle?)
    mentorship_group(mentorship_cycle: mentorship_cycle) || mentorship_groups.build(mentorship_cycle: mentorship_cycle)
  end

  # Find
  def mentorship_registration(mentorship_cycle:)
    raise('expected an MentorshipCycle') unless mentorship_cycle.class.respond_to?(:effective_mentorships_cycle?)
    mentorship_registrations.find { |mentorship_registration| mentorship_registration.mentorship_cycle_id == mentorship_cycle.id }
  end

  # Find or build
  def build_mentorship_registration(mentorship_cycle:)
    raise('expected an MentorshipCycle') unless mentorship_cycle.class.respond_to?(:effective_mentorships_cycle?)
    mentorship_registration(mentorship_cycle: mentorship_cycle) || mentorship_registrations.build(mentorship_cycle: mentorship_cycle)
  end

end
