require 'effective_resources'
require 'effective_datatables'
require 'effective_mentorships/engine'
require 'effective_mentorships/version'

module EffectiveMentorships

  def self.config_keys
    [
      :mentorship_cycles_table_name, :mentorship_bulk_groups_table_name, :mentorship_groups_table_name, :mentorship_registrations_table_name,
      :mentorship_group_class_name, :mentorship_registration_class_name, :mentorship_bulk_group_class_name,
      :layout,
      :mailer, :parent_mailer, :deliver_method, :mailer_layout, :mailer_sender, :mailer_froms, :mailer_admin, :mailer_subject,
    ]
  end

  include EffectiveGem

  def self.mailer_class
    mailer&.constantize || Effective::MentorshipsMailer
  end

  def self.MentorshipBulkGroup
    mentorship_bulk_group_class_name&.constantize || Effective::MentorshipBulkGroup
  end

  def self.MentorshipGroup
    mentorship_group_class_name&.constantize || Effective::MentorshipGroup
  end

  def self.MentorshipRegistration
    mentorship_registration_class_name&.constantize || Effective::MentorshipRegistration
  end

  def self.MentorshipCycle
    Effective::MentorshipCycle
  end

  def self.current_mentorship_cycle(date: nil)
    date ||= Time.zone.now
    mentorship_cycles = Effective::MentorshipCycle.all.reorder(start_at: :asc).all.where('start_at <= ?', date)
    mentorship_cycles.to_a.last
  end

  def self.previous_mentorship_cycle(date: nil)
    date ||= Time.zone.now
    mentorship_cycles = Effective::MentorshipCycle.all.reorder(start_at: :asc).all.where('start_at <= ?', date)
    mentorship_cycles.to_a.last(2).first
  end

end
