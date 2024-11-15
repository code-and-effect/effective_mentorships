# frozen_string_literal: true

# EffectiveMentorshipsRegistration
#
# Mark your group model with effective_mentorships_registration to get all the includes

module EffectiveMentorshipsRegistration
  extend ActiveSupport::Concern

  module Base
    def effective_mentorships_registration
      include ::EffectiveMentorshipsRegistration
    end
  end

  module ClassMethods
    def effective_mentorships_registration?; true; end

    def mentorship_roles
      ['A Mentor', 'A Protege', 'Both']
    end
  end

  included do
    attr_accessor :current_user

    log_changes if respond_to?(:log_changes)
    acts_as_tokened

    # rich_text_body
    has_many_rich_texts

    # Effective Scoped
    belongs_to :mentorship_cycle, class_name: 'Effective::MentorshipCycle', counter_cache: true

    # App Scoped
    belongs_to :user

    effective_resource do
      # Preferences
      mentorship_role   :string

      token             :string

      timestamps
    end

    scope :deep, -> { includes(:rich_texts, :user, :mentorship_cycle) }
    scope :sorted, -> { order(:id) }

    before_validation do
      self.user ||= current_user
    end

    # User
    validates :user_id, uniqueness: { scope: [:mentorship_cycle_id] }
    validates :mentorship_role, presence: true, inclusion: { in: mentorship_roles }
  end

  # Instance Methods
  def to_s
    mentorship_role.presence || model_name.human
  end
end
