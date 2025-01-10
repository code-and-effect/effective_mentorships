module Effective
  class MentorshipGroupUser < ActiveRecord::Base
    # Effective scoped
    belongs_to :mentorship_cycle, class_name: 'Effective::MentorshipCycle'

    # App scoped
    belongs_to :mentorship_group
    belongs_to :user, polymorphic: true

    effective_resource do
      mentorship_role   :string

      # Copied from user
      name    :string
      email   :string

      position  :integer

      timestamps
    end

    scope :deep, -> { includes(:mentorship_cycle, :mentorship_group, :user) }
    scope :sorted, -> { order(:mentorship_cycle_id).order(:position) }

    # Assign position and cycle
    before_validation(if: -> { mentorship_group.present? }) do
      self.position ||= (mentorship_group.mentorship_group_users.map(&:position).compact.max || -1) + 1
      self.mentorship_cycle = mentorship_group.mentorship_cycle
    end

    # Denormalized data for searching
    before_validation(if: -> { user.present? }) do
      assign_attributes(name: user.to_s, email: user.email)
    end

    validates :user_id, uniqueness: { scope: [:mentorship_group_id] }

    def to_s
      user.to_s.presence || model_name.human
    end

    def mentorship_registration
      user.mentorship_registrations.find { |mentorship_registration| mentorship_registration.mentorship_cycle_id == mentorship_cycle.id }
    end

    def mentor?
      mentorship_role.to_s == 'mentor'
    end
  
    def mentee?
      mentorship_role.to_s == 'mentee'
    end

    def other?
      !mentor? && !mentee?
    end

  end
end
