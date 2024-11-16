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
    # rich_text_admin_notes

    # Effective Scoped
    belongs_to :mentorship_cycle, class_name: 'Effective::MentorshipCycle', counter_cache: true

    has_many :mentorship_group_users, class_name: 'Effective::MentorshipGroupUser', dependent: :delete_all
    accepts_nested_attributes_for :mentorship_group_users, allow_destroy: true

    effective_resource do
      title         :string

      archived      :boolean
      token         :string

      timestamps
    end

    scope :deep, -> { includes(:mentorship_cycle, :rich_texts, mentorship_group_users: [:user]) }
    scope :sorted, -> { order(:id) }

    validates :title, presence: true, uniqueness: true
  end

  # Instance Methods
  def to_s
    model_name.human
  end

  def mentorship_group_user(user:)
    mentorship_group_users.find { |mgu| mgu.user == user }
  end

end
