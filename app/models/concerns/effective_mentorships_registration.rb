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
      [:mentor, :mentee]
    end

    def categories
      ['General', 'Industry Specific']
    end

    def locations
      ['Canada', 'United States']
    end

    def venues
      ['virtual', 'in person', 'either']
    end
  end

  included do
    attr_accessor :current_user

    log_changes if respond_to?(:log_changes)
    acts_as_tokened

    has_many_rich_texts
    # rich_text_comments

    # Effective Scoped
    belongs_to :mentorship_cycle, class_name: 'Effective::MentorshipCycle', counter_cache: true

    # App Scoped
    belongs_to :user

    effective_resource do
      title              :string # Auto generated

      # Registration
      opt_in             :boolean # Opt in to this mentorship cycle
      mentorship_role    :string

      # Pairing info
      category           :string # Professional category interests
      venue              :string # Preferred venue virtual or in person
      location           :string # Closest city of residence

      # Mentor only fields
      mentor_multiple_mentees         :boolean
      mentor_multiple_mentees_limit   :integer

      # Mentee only fields
      # None

      token             :string
      timestamps
    end

    # Always assign title
    before_validation do
      self.title = [user, (opt_in ? mentorship_role : 'Opt Out')].compact.join(' - ')
    end

    with_options(if: -> { opt_in? }) do
      validates :mentorship_role, presence: true
      validates :category, presence: true
      validates :venue, presence: true
      validates :location, presence: true
    end

    validates :mentor_multiple_mentees_limit, numericality: { greater_than: 0 }, if: -> { opt_in? && mentor_multiple_mentees? }

    scope :deep, -> { includes(:rich_texts, :user, :mentorship_cycle) }
    scope :sorted, -> { order(:id) }

    scope :mentors, -> { where(mentorship_role: :mentor) }
    scope :mentees, -> { where(mentorship_role: :mentee) }
    scope :opt_in, -> { where(opt_in: true) }
    scope :opt_out, -> { where(opt_in: false) }

    # User
    validates :user_id, uniqueness: { scope: [:mentorship_cycle_id] }
  end

  # Instance Methods
  def to_s
    title.presence || model_name.human
  end

  def mentor?
    mentorship_role == 'mentor'
  end

  def mentee?
    mentorship_role == 'mentee'
  end

end
