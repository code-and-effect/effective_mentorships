module Effective
  class MentorshipCycle < ActiveRecord::Base
    has_many_rich_texts
    # rich_text_registration_content
    # rich_text_group_content

    has_many :mentorship_groups
    has_many :mentorship_registrations

    log_changes(except: [:mentorship_groups, :mentorship_registrations]) if respond_to?(:log_changes)

    effective_resource do
      title                 :string       # 2021 Mentorship Program

      # Availability starts and ends at
      start_at              :datetime
      end_at                :datetime

      registration_start_at :datetime
      registration_end_at   :datetime

      max_pairings_mentee   :integer

      mentorship_groups_count         :integer
      mentorship_registrations_count  :integer

      timestamps
    end

    scope :deep, -> { includes(:rich_texts) }

    scope :shallow, -> { select(:id, :title) }
    scope :sorted, -> { order(:id) }

    scope :upcoming, -> { where('start_at > ?', Time.zone.now) }
    scope :past, -> { where('end_at < ?', Time.zone.now) }

    scope :available, -> { where('start_at <= ? AND (end_at > ? OR end_at IS NULL)', Time.zone.now, Time.zone.now) }
    scope :registrable, -> { where('registration_start_at <= ? AND (registration_end_at > ? OR registration_end_at IS NULL)', Time.zone.now, Time.zone.now) }

    validates :title, presence: true, uniqueness: true
    validates :start_at, presence: true
    validates :max_pairings_mentee, numericality: { greater_than_or_equal_to: 1, allow_blank: true }

    validate(if: -> { start_at.present? && end_at.present? }) do
      errors.add(:end_at, 'must be after the start date') unless end_at > start_at
    end

    validate(if: -> { registration_start_at.present? && registration_end_at.present? }) do
      errors.add(:registration_end_at, 'must be after the registration start date') unless registration_end_at > registration_start_at
    end

    before_destroy do
      raise("cannot destroy mentorship cycle with mentorship groups") if mentorship_groups.length > 0
      raise("cannot destroy mentorship cycle with mentorship registrations") if mentorship_registrations.length > 0
    end

    def self.effective_mentorships_cycle?
      true
    end

    def self.latest_cycle
      order(start_at: :desc).first
    end

    def to_s
      title.presence || model_name.human
    end

    # Returns a duplicated event object, or throws an exception
    def duplicate
      MentorshipCycle.new(attributes.except('id', 'updated_at', 'created_at', 'token')).tap do |resource|
        # Duplicate mentorship cycle
        resource.title = title + ' (Copy)'

        # Duplicate all date fields and move them ahead 1-year
        resource.start_at = start_at&.advance(years: 1)
        resource.end_at = end_at&.advance(years: 1)
        resource.registration_start_at = registration_start_at&.advance(years: 1)
        resource.registration_end_at = registration_end_at&.advance(years: 1)

        # Duplicate all rich texts
        rich_texts.each { |rt| resource.send("rich_text_#{rt.name}=", rt.body) }
      end
    end

    def available?
      started? && !ended?
    end

    def started?
      start_at.present? && Time.zone.now >= start_at
    end

    def ended?
      end_at.present? && end_at < Time.zone.now
    end

    def registrable?
      registration_started? && !registration_ended?
    end

    def registration_started?
      registration_start_at.present? && Time.zone.now >= registration_start_at
    end

    def registration_ended?
      registration_end_at.present? && registration_end_at < Time.zone.now
    end

    def available_date
      if start_at && end_at
        "#{start_at.strftime('%F')} to #{end_at.strftime('%F')}"
      elsif start_at
        "#{start_at.strftime('%F')}"
      end
    end

    def registrable_date
      if registration_start_at && registration_end_at
        "#{registration_start_at.strftime('%F')} to #{registration_end_at.strftime('%F')}"
      elsif registration_start_at
        "#{registration_start_at.strftime('%F')}"
      end
    end

  end
end
