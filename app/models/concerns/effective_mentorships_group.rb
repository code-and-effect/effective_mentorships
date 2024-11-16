# frozen_string_literal: true

# EffectiveMentorshipsGroup
#
# Mark your group model with effective_mentorships_group to get all the includes

module EffectiveMentorshipsGroup
  extend ActiveSupport::Concern

  module Base
    def effective_mentorships_group
      include ::EffectiveMentorshipsGroup
    end
  end

  module ClassMethods
    def effective_mentorships_group?; true; end
  end

  included do
    acts_as_archived
    acts_as_tokened

    log_changes if respond_to?(:log_changes)

    has_many_rich_texts
    # rich_text_body

    # Effective Scoped
    belongs_to :mentorship_cycle, class_name: 'Effective::MentorshipCycle', counter_cache: true

    # App Scoped
    belongs_to :user

    effective_resource do
      archived      :boolean

      token         :string

      timestamps
    end

    scope :deep, -> { includes(:rich_texts) }
    scope :sorted, -> { order(:id) }
  end

  # Instance Methods
  def to_s
    model_name.human
  end

end
