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
    acts_as_job_status
    log_changes if respond_to?(:log_changes)

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
      mentorship_groups_count :integer

      email_form_skip         :boolean

      # Acts as Wizard
      wizard_steps            :text, permitted: false

      # Acts as Tokened
      token                   :string

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
    [model_name.human, ("##{id}" if id.present?)].compact.join(' ')
  end

  def max_pairings_mentee
    raise('expected a mentorship cycle') unless mentorship_cycle.present?
    mentorship_cycle.max_pairings_mentee || 10 # Hardcode a sane limit. This shouldn't ever be used. The registrations is limited to 1-5
  end

  def mentors_mentorship_registrations
    raise('expected a mentorship cycle') unless mentorship_cycle.present?
    EffectiveMentorships.MentorshipRegistration.opt_in.mentors.where(mentorship_cycle: mentorship_cycle)
  end

  def mentees_mentorship_registrations
    raise('expected a mentorship cycle') unless mentorship_cycle.present?
    EffectiveMentorships.MentorshipRegistration.opt_in.mentees.where(mentorship_cycle: mentorship_cycle)
  end

  def mentorship_group_for(user:)
    mentorship_groups.find { |mentorship_group| mentorship_group.mentorship_group_user(user: user).present? }
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
    EffectiveMentorships.MentorshipRegistration.uncached do
      # First pass
      # Create groups with 1 mentor and 1 best matching mentee each

      # In-person
      mentors_mentorship_registrations.without_groups.in_person.find_each do |mentor_registration|
        mentorship_group = build_mentorship_group(mentor_registration)
        mentorship_group&.save!
      end

      # Either
      mentors_mentorship_registrations.without_groups.either.find_each do |mentor_registration|
        mentorship_group = build_mentorship_group(mentor_registration)
        mentorship_group&.save!
      end

      # Virtual
      mentors_mentorship_registrations.without_groups.virtual.find_each do |mentor_registration|
        mentorship_group = build_mentorship_group(mentor_registration)
        mentorship_group&.save!
      end

      # Second pass
      # Create groups with 1 mentor and any mentee
      mentors_mentorship_registrations.without_groups.find_each do |mentor_registration|
        mentorship_group = build_mentorship_group(mentor_registration, any_mentee: true)
        mentorship_group&.save!
      end

      # Third pass
      # Add best matching mentees to groups where mentor wants more than 1 mentee
      if max_pairings_mentee > 1
        fillable_mentors_mentorship_registrations = mentors_mentorship_registrations.multiple_mentees.with_groups_from(self)

        # In-person
        fillable_mentors_mentorship_registrations.in_person.find_each do |mentor_registration|
          mentorship_group = fill_mentorship_group(mentor_registration)
          mentorship_group&.save!
        end

        # Either
        fillable_mentors_mentorship_registrations.either.find_each do |mentor_registration|
          mentorship_group = fill_mentorship_group(mentor_registration)
          mentorship_group&.save!
        end

        # Virtual
        fillable_mentors_mentorship_registrations.virtual.find_each do |mentor_registration|
          mentorship_group = fill_mentorship_group(mentor_registration)
          mentorship_group&.save!
        end
      end

      # Fourth pass
      # Add any mentees to groups where mentor wants more than 1 mentee
      if max_pairings_mentee > 1
        fillable_mentors_mentorship_registrations = mentors_mentorship_registrations.multiple_mentees.with_groups_from(self)

        fillable_mentors_mentorship_registrations.find_each do |mentor_registration|
          mentorship_group = fill_mentorship_group(mentor_registration, any_mentee: true)
          mentorship_group&.save!
        end
      end

      # Call after_save callback on all mentorship groups
      mentorship_groups.each do |mentorship_group|
        mentorship_group.assign_attributes(save_as_draft: true)
        after_save_mentorship_group!(mentorship_group)
      end
    end

    wizard_steps[:grouping] ||= Time.zone.now
    save!
  end

  def build_mentorship_group(mentor_registration, any_mentee: false)
    raise('expected a mentorship registration') unless mentor_registration.class.try(:effective_mentorships_registration?)
    raise('expected a mentor mentorship registration') unless mentor_registration.mentor?

    mentor = mentor_registration.user
    raise('expected a mentorship user') unless mentor.class.try(:effective_mentorships_user?)

    # Select the best matching mentees for this mentor registration
    mentee_registration = find_best_mentee_registration(mentor_registration)

    if any_mentee
      mentee_registration ||= find_any_mentee_registration(mentor_registration) 
    end

    return unless mentee_registration.present?

    mentee = mentee_registration.user
    raise('expected a mentorship user') unless mentee.class.try(:effective_mentorships_user?)

    # Create a new group in draft state
    mentorship_group = mentorship_groups.build(mentorship_cycle: mentorship_cycle, save_as_draft: true)
    mentorship_group.build_mentor(user: mentor)
    mentorship_group.build_mentee(user: mentee)

    # Return the group ready to be saved
    mentorship_group
  end

  def fill_mentorship_group(mentor_registration, any_mentee: false)
    raise('expected a mentorship registration') unless mentor_registration.class.try(:effective_mentorships_registration?)
    raise('expected a mentor mentorship registration') unless mentor_registration.mentor?

    mentor = mentor_registration.user
    raise('expected a mentorship user') unless mentor.class.try(:effective_mentorships_user?)

    # Find the existing mentorship group that we previously created
    mentorship_group = mentorship_group_for(user: mentor)
    return unless mentorship_group.present?

    # Fill this group to limit of number of mentees
    limit = [mentor_registration.mentor_multiple_mentees_limit.to_i, max_pairings_mentee].min
    fill_mentees = (limit - mentorship_group.mentorship_group_users.select(&:mentee?).length) # dont use mentorship_group_mentees here
    return unless fill_mentees > 0

    # We only support 1 mentor and many mentees
    fill_mentees.times do
      mentee_registration = find_best_mentee_registration(mentor_registration)

      if any_mentee
        mentee_registration ||= find_any_mentee_registration(mentor_registration) 
      end

      if mentee_registration.present?
        mentee = mentee_registration.user
        raise('expected a mentorship user') unless mentee.class.try(:effective_mentorships_user?)

        mentorship_group.build_mentee(user: mentee)
      end
    end

    # Return the group ready to be saved
    mentorship_group.assign_attributes(save_as_draft: true)
    mentorship_group
  end

  def find_best_mentee_registration(mentor_registration)
    case mentor_registration.venue
    when 'In-person' 
      find_best_in_person_mentee_registration(mentor_registration)
    when 'Either' 
      find_best_either_mentee_registration(mentor_registration)
    when 'Virtual' 
      find_best_virtual_mentee_registration(mentor_registration)
    else
      raise("unexpected venue: #{mentor_registration.venue}")
    end
  end

  def find_any_mentee_registration(mentor_registration)
    mentees_mentorship_registrations.without_groups.order(:id).first
  end

  def find_best_in_person_mentee_registration(mentor_registration)
    registrations = mentees_mentorship_registrations.without_groups.order(:id)

    # In-person, same location, same category
    registration ||= registrations.in_person.where(location: mentor_registration.location, category: mentor_registration.category).first

    # In-person, same location, any category
    registration ||= registrations.in_person.where(location: mentor_registration.location).first

    # Either, same location, same category
    registration ||= registrations.either.where(location: mentor_registration.location, category: mentor_registration.category).first

    # Either, same location, any category
    registration ||= registrations.either.where(location: mentor_registration.location).first

    # Might be nil
    registration
  end

  def find_best_either_mentee_registration(mentor_registration)
    raise('expected an in-person mentor registration') unless mentor_registration.either?

    registrations = mentees_mentorship_registrations.without_groups.order(:id)

    # Either, same location, same category
    registration ||= registrations.either.where(location: mentor_registration.location, category: mentor_registration.category).first

    # In-person, same location, same category
    registration ||= registrations.in_person.where(location: mentor_registration.location, category: mentor_registration.category).first

    # Either, any location, same category
    registration ||= registrations.either.where(category: mentor_registration.category).first

    # In-person, same location, any category
    registration ||= registrations.in_person.where(location: mentor_registration.location).first

    # Virtual, same location, same category 
    registration ||= registrations.virtual.where(location: mentor_registration.location, category: mentor_registration.category).first

    # Virtual, any location, same category
    registration ||= registrations.virtual.where(category: mentor_registration.category).first

    # Either any
    registration ||= registrations.either.first

    # Virtual any
    registration ||= registrations.virtual.first

    # Might be nil
    registration
  end

  def find_best_virtual_mentee_registration(mentor_registration)
    raise('expected an in-person mentor registration') unless mentor_registration.virtual?

    registrations = mentees_mentorship_registrations.without_groups.order(:id)

    # Virtual, same location, same category 
    registration ||= registrations.virtual.where(location: mentor_registration.location, category: mentor_registration.category).first

    # Virtual, any location, same category
    registration ||= registrations.virtual.where(category: mentor_registration.category).first

    # Either, same location, same category
    registration ||= registrations.either.where(location: mentor_registration.location, category: mentor_registration.category).first

    # Either, any location, same category
    registration ||= registrations.either.where(category: mentor_registration.category).first

    # Virtual any
    registration ||= registrations.virtual.first

    # Either any
    registration ||= registrations.either.first

    # Might be nil
    registration
  end

  # Nothing to do. Override me.
  def after_save_mentorship_group!(mentorship_group)
  end

end
