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

    # Don't change these roles
    def mentorship_roles
      [:mentor, :mentee]
    end

    # Don't change these venues
    def venues
      ['Virtual', 'In-person', 'Either']
    end

    def categories
      ['General', 'Industry Specific']
    end

    def locations
      ['Canada', 'United States']
    end
  end

  included do
    log_changes if respond_to?(:log_changes)
    acts_as_tokened

    has_many_rich_texts
    # rich_text_comments

    # Effective Scoped
    belongs_to :mentorship_cycle, class_name: 'Effective::MentorshipCycle', counter_cache: true
    has_many :mentorship_group_users, class_name: 'Effective::MentorshipGroupUser', inverse_of: :mentorship_registration, dependent: :nullify

    # App Scoped
    belongs_to :user
    belongs_to :parent, polymorphic: true, optional: true # A FeePayment if this was done through a fee payment
    has_many :mentorship_groups, through: :mentorship_group_users
    
    effective_resource do
      title              :string # Auto generated

      # Registration
      opt_in             :boolean # Opt in to this mentorship cycle
      accept_declaration :boolean
      mentorship_role    :string

      # Pairing info
      category           :string # Professional category interests
      venue              :string # Preferred venue virtual or in person
      location           :string # Closest city of residence

      # Mentor only fields
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
      validates :accept_declaration, acceptance: true
    end

    validates :mentor_multiple_mentees_limit, numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }, if: -> { opt_in? && mentor? }

    scope :deep, -> { includes(:rich_texts, :user, :mentorship_cycle) }
    scope :sorted, -> { order(:id) }

    scope :mentors, -> { where(mentorship_role: :mentor) }
    scope :mentees, -> { where(mentorship_role: :mentee) }
    scope :opt_in, -> { where(opt_in: true) }
    scope :opt_out, -> { where(opt_in: false) }
    scope :opt_in_without_groups, -> { opt_in.without_groups }

    scope :in_person, -> { where(venue: 'In-person') }
    scope :virtual, -> { where(venue: 'Virtual') }
    scope :either, -> { where(venue: 'Either') }

    scope :with_groups, -> { 
      group_users = Effective::MentorshipGroupUser.all
      where(id: group_users.select(:mentorship_registration_id))
    }

    scope :without_groups, -> {
      group_users = Effective::MentorshipGroupUser.all
      where.not(id: group_users.select(:mentorship_registration_id))
    }

    scope :with_groups, -> { 
      group_users = Effective::MentorshipGroupUser.all
      where(id: group_users.select(:mentorship_registration_id))
    }

    scope :with_groups_from, -> (mentorship_bulk_group) { 
      groups = EffectiveMentorships.MentorshipGroup.where(mentorship_bulk_group: mentorship_bulk_group)
      group_users = Effective::MentorshipGroupUser.where(mentorship_group_id: groups.select(:mentorship_group_id))

      where(id: group_users.select(:mentorship_registration_id))
    }

    scope :multiple_mentees, -> { mentors.where('mentor_multiple_mentees_limit > 1') }

    # User
    validates :user_id, uniqueness: { scope: [:mentorship_cycle_id] }
  end

  # Instance Methods
  def to_s
    title.presence || model_name.human
  end

  def short_category
    return category unless category.to_s.include?('(') && category.to_s.include?(')')
    category.to_s.split('(').first.strip
  end

  def details
    [
      short_category.presence, 
      venue.presence, 
      location.presence, 
      ("Limit #{mentor_multiple_mentees_limit}" if mentor? && mentor_multiple_mentees_limit.present?)
    ].compact.join(', ').html_safe
  end

  # Mentorship roles
  def mentor?
    mentorship_role.to_s == 'mentor'
  end

  def mentee?
    mentorship_role.to_s == 'mentee'
  end

  # Venues
  def in_person?
    venue == 'In-person'
  end

  def virtual?
    venue == 'Virtual'
  end

  def either?
    venue == 'Either'
  end

end
