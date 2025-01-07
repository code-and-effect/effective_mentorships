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

    acts_as_wizard(
      start: 'Start',
      group: 'Preview',
      grouping: 'Grouping',
      review: 'Review',
      notify: 'Notify',
      notifying: 'Notifying',
      notified: 'Notified',
      finished: 'Finished'
    )

    # Effective Scoped
    belongs_to :mentorship_cycle, class_name: 'Effective::MentorshipCycle'

    # Application Scoped
    has_many :mentorship_groups, -> { order(:id) }, inverse_of: :mentorship_bulk_group, dependent: :nullify
    accepts_nested_attributes_for :mentorship_groups, allow_destroy: true

    effective_resource do
      title                         :string
      mentorships_user_class_name   :string

      mentorship_groups_count       :integer

      email_form_skip   :boolean

      # Email
      subject           :string
      body              :text

      from              :string
      cc                :string
      bcc               :string
      content_type      :string

      # Acts as Wizard
      wizard_steps            :text, permitted: false

      # Acts as tokened
      token             :string

      timestamps
    end

    scope :deep, -> { all }
    scope :sorted, -> { order(:id) }

    before_validation(if: -> { current_user.present? }) do
      self.mentorships_user_class_name ||= current_user.class.name
    end

    validates :mentorships_user_class_name, presence: true
  end

  def to_s
    model_name.human
  end

  def group!
    binding.pry
    save!
  end

  def mentorship_user_scope
    mentorships_user_class_name.constantize.all if mentorships_user_class_name.present?
  end

  # To be overrriden to implement selection criteria
  def mentorship_mentors
    raise('expected a mentorship cycle') unless mentorship_cycle.present?
    mentorship_user_scope.mentorships_opted_in_mentors(mentorship_cycle)
  end

  # Maybe to be overridden.
  def mentorship_mentees
    raise('expected a mentorship cycle') unless mentorship_cycle.present?
    mentorship_user_scope.mentorships_opted_in_mentees(mentorship_cycle)
  end

  # def create_bulk_audit_job!
  #   raise('must be persisted') unless persisted?

  #   Effective::CpdBulkAuditJob.perform_later(id)
  # end

  # # Called by Effective::CpdBulkAuditJob
  # def create_audits!
  #   save!

  #   @auditees = cpd_auditees.reorder('RANDOM()').limit(audits)
  #   @reviewers = cpd_audit_reviewers.reorder('RANDOM()').limit(audits).to_a

  #   @auditees.each do |auditee|
  #     reviewers = audit_reviewers_per_audit.times.map { next_audit_reviewer() }

  #     begin
  #       cpd_audit = build_cpd_audit(auditee, reviewers)
  #       cpd_audit.save!
  #       after_create_audit!(cpd_audit)
  #     rescue => e
  #       EffectiveLogger.error(e.message, associated: self) if defined?(EffectiveLogger)
  #       ExceptionNotifier.notify_exception(e, data: { user_id: auditee.id }) if defined?(ExceptionNotifier)
  #       raise(e) if (Rails.env.test? || Rails.env.development?)
  #     end
  #   end

  #   true
  # end

end
