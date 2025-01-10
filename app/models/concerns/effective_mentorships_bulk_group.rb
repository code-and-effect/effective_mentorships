# frozen_string_literal: true

# EffectiveCpdBulkAudit
#
# Mark your owner model with effective_cpd_bulk_audit to get all the includes

module EffectiveMentorshipsBulkGroup
  extend ActiveSupport::Concern

  module Base
    def effective_mentorships_bulk_group
      include ::EffectiveMentorshipsBulkGroup
    end
  end

  module ClassMethods
    def effective_mentorships_bulk_group?; true; end
  end

  included do
    attr_accessor :current_user

    # acts_as_email_notification # effective_resources
    log_changes
    acts_as_job_status

    acts_as_wizard(
      start: 'Start',
      group: 'Preview',
      grouping: 'Grouping',
      review: 'Review',
      publish: 'Publish',
      notify: 'Notify',
      notifying: 'Notifying',
      finished: 'Finished'
    )

    # Effective Scoped
    belongs_to :mentorship_cycle, class_name: 'Effective::MentorshipCycle'

    # Application Scoped
    has_many :mentorship_groups, -> { order(:id) }, inverse_of: :mentorship_bulk_group, dependent: :nullify
    accepts_nested_attributes_for :mentorship_groups, allow_destroy: true

    effective_resource do
      mentorship_groups_count       :integer

      email_form_skip   :boolean

      # Acts as Wizard
      wizard_steps            :text, permitted: false

      # Acts as Tokened
      token             :string

      # Acts as Job Status
      job_status            :string
      job_started_at        :datetime
      job_ended_at          :datetime
      job_error             :text

      timestamps
    end

    scope :deep, -> { all }
    scope :sorted, -> { order(:id) }
  end

  def to_s
    model_name.human
  end

  def max_pairings_mentee
    mentorship_cycle&.max_pairings_mentee
  end

  def mentors_mentorship_registrations
    raise('expected a mentorship cycle') unless mentorship_cycle.present?

    registrations = EffectiveMentorships.MentorshipRegistration.opt_in.mentors.where(mentorship_cycle: mentorship_cycle)
    existing = Effective::MentorshipGroupUser.where(mentorship_cycle: mentorship_cycle)

    registrations.where.not(user_id: existing.select(:user_id))
  end

  def mentees_mentorship_registrations
    raise('expected a mentorship cycle') unless mentorship_cycle.present?

    registrations = EffectiveMentorships.MentorshipRegistration.opt_in.mentees.where(mentorship_cycle: mentorship_cycle)
    existing = Effective::MentorshipGroupUser.where(mentorship_cycle: mentorship_cycle)

    registrations.where.not(user_id: existing.select(:user_id))
  end

  def group!
    # Calls create_groups! and save!
    perform_with_job_status! { Effective::MentorshipsBulkCreateGroupsJob.perform_later(id) }
  end

  def publish!
    mentorship_groups.deep.find_each { |mentorship_group| mentorship_group.publish! }
    save!
  end

  def notify!
    return skip_notify! if email_form_skip?

    # Calls notify_groups! and save!
    perform_with_job_status! { Effective::MentorshipsBulkNotifyGroupsJob.perform_later(id) }
  end

  def skip_notify!
    wizard_steps[:notifying] ||= Time.zone.now
    wizard_steps[last_wizard_step] ||= Time.zone.now
    save!
  end

  def notifying!
    wizard_steps[last_wizard_step] ||= Time.zone.now # Also finish the whole wizard
    save!
  end

  # Called by Effective::MentorshipsBulkNotifyGroupsJob
  def notify_groups!
    mentorship_groups.published.not_notified.find_each do |mentorship_group|
      mentorship_group.notify!
    end

    wizard_steps[:notifying] ||= Time.zone.now
    save!
  end

  # Called by Effective::MentorshipsBulkCreateGroupsJob
  def create_groups!
    EffectiveMentorships.MentorshipGroup.delete_all
    Effective::MentorshipGroupUser.delete_all

    # Create groups with 1 mentor each
    mentors_mentorship_registrations.find_each do |mentor_registration|
      mentorship_group = build_mentorship_group(mentor_registration)
      next unless mentorship_group.present?

      mentorship_group.save!
      after_create_mentorship_group!(mentorship_group)
    end

    wizard_steps[:grouping] ||= Time.zone.now
    save!
  end

  def build_mentorship_group(mentor_registration)
    raise('expected a mentorship registration') unless mentor_registration.class.try(:effective_mentorships_registration?)
    raise('expected a mentor mentorship registration') unless mentor_registration.mentor?

    mentor = mentor_registration.user
    raise('expected a mentorship user') unless mentor.class.try(:effective_mentorships_user?)

    # Create a new group in draft state
    mentorship_group = mentorship_groups.build(mentorship_cycle: mentorship_cycle, save_as_draft: true)
    mentorship_group.build_mentor(user: mentor_registration.user)

    # Select the best matching mentees for this mentor registration
    mentee_registration = find_best_mentee_registration(mentor_registration)
    return unless mentee_registration.present?

    mentee = mentee_registration.user
    raise('expected a mentorship user') unless mentee.class.try(:effective_mentorships_user?)

    mentorship_group.build_mentee(user: mentee)

    # Return the group ready to be saved
    mentorship_group
  end

  def find_best_mentee_registration(mentor_registration)
    registrations = mentees_mentorship_registrations.reorder('RANDOM()')

    # Match by all
    registration = registrations.where(category: mentor_registration.category, location: mentor_registration.location, venue: mentor_registration.venue).first
    return registration if registration.present?

    # Match by location and venue
    registration = registrations.where(location: mentor_registration.location, venue: mentor_registration.venue).first
    return registration if registration.present?

    # Match by location and venue
    registration = registrations.where(location: mentor_registration.location).first
    return registration if registration.present?

    # Fallback. Might be nil.
    registrations.first
  end

  # Nothing to do. Override me.
  def after_create_mentorship_group!(mentorship_group)
  end

end
