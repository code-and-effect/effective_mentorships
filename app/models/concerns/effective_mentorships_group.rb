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
    acts_as_published
    acts_as_tokened
    log_changes if respond_to?(:log_changes)

    has_many_rich_texts
    # rich_text_admin_notes

    # Application Scoped
    belongs_to :mentorship_bulk_group, optional: true, counter_cache: true

    # Effective Scoped
    belongs_to :mentorship_cycle, class_name: 'Effective::MentorshipCycle', counter_cache: true

    has_many :mentorship_group_users, class_name: 'Effective::MentorshipGroupUser', dependent: :delete_all
    accepts_nested_attributes_for :mentorship_group_users, allow_destroy: true

    has_many :mentorship_group_mentors, -> { where(mentorship_role: :mentor) }, class_name: 'Effective::MentorshipGroupUser'
    has_many :mentorship_group_mentees, -> { where(mentorship_role: :mentee) }, class_name: 'Effective::MentorshipGroupUser'

    effective_resource do
      title         :string

      # Track email
      last_notified_at    :datetime

      # Acts as Published
      published_start_at  :datetime
      published_end_at    :datetime

      # Acts as Tokened
      token         :string

      timestamps
    end

    scope :deep, -> { includes(:mentorship_cycle, :rich_texts, mentorship_group_users: [:user]) }
    scope :sorted, -> { order(:id) }

    scope :notified, -> { where.not(last_notified_at: nil) }
    scope :not_notified, -> { where(last_notified_at: nil) }

    # When created on the MentorshipBulkGroup Review screen
    before_validation(if: -> { mentorship_bulk_group.present? }) do
      self.mentorship_cycle ||= mentorship_bulk_group.mentorship_cycle
    end

    before_save :assign_title # Assign computed title always
  end

  # Instance Methods
  def to_s
    title.presence || model_name.human
  end

  def assign_title
    if present_mentorship_group_users.blank?
      assign_attributes(title: "Empty")
    else
      mentor_names = mentors.map { |user| user.try(:first_name) || user.to_s.split(' ').first }.sort
      mentee_names = mentees.map { |user| user.try(:first_name) || user.to_s.split(' ').first }.sort
      other_names = others.map { |user| user.try(:first_name) || user.to_s.split(' ').first }.sort

      assign_attributes(title: (mentor_names + mentee_names + other_names).join(', '))
    end
  end

  def notify!
    present_mentorship_group_users.each do |mentorship_group_user|
      begin
        case mentorship_group_user.mentorship_role.to_s
        when 'mentor'
          EffectiveMentorships.send_email(:mentorship_group_created_to_mentor, mentorship_group_user)
        when 'mentee'
          EffectiveMentorships.send_email(:mentorship_group_created_to_mentee, mentorship_group_user)
        end
      rescue => e
        EffectiveLogger.error(e.message, associated: self) if defined?(EffectiveLogger)
        ExceptionNotifier.notify_exception(e, data: { user_id: mentorship_group_user.user_id }) if defined?(ExceptionNotifier)
        raise(e) if (Rails.env.test? || Rails.env.development?)
      end
    end

    update!(last_notified_at: Time.zone.now)
  end

  # Find
  def mentorship_group_user(user:)
    mentorship_group_users.find { |mgu| mgu.user == user }
  end

  # Find or build
  def build_mentorship_group_user(user:, mentorship_role:)
    raise("unexpected mentorship role: #{mentorship_role}") unless EffectiveMentorships.MentorshipRegistration.mentorship_roles.include?(mentorship_role)
    mentorship_group_user(user: user) || mentorship_group_users.build(user: user, mentorship_role: mentorship_role)
  end

  # Find or build
  def build_mentor(user:)
    build_mentorship_group_user(user: user, mentorship_role: :mentor)
  end

  # Find or build
  def build_mentee(user:)
    build_mentorship_group_user(user: user, mentorship_role: :mentee)
  end

  def present_mentorship_group_users
    mentorship_group_users.reject(&:marked_for_destruction?)
  end

  def mentors
    present_mentorship_group_users.select(&:mentor?).map(&:user)
  end

  def mentees
    present_mentorship_group_users.select(&:mentee?).map(&:user)
  end

  def others
    present_mentorship_group_users.select(&:other?).map(&:user)
  end

end
