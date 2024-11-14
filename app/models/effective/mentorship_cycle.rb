module Effective
  class MentorshipCycle < ActiveRecord::Base
    has_many_rich_texts

    has_many :mentorship_groups

    if respond_to?(:log_changes)
      log_changes(except: [:mentorship_groups])
    end

    effective_resource do
      title                 :string       # 2021 Mentorship Program

      # Availability starts and ends at
      start_at              :datetime
      end_at                :datetime

      registration_start_at :datetime
      registration_end_at   :datetime

      max_pairings_mentor   :integer
      max_pairings_mentee   :integer

      timestamps
    end

    scope :deep, -> { includes(:rich_texts) }

    scope :shallow, -> { select(:id, :title) }
    scope :sorted, -> { order(:id) }

    scope :upcoming, -> { where('start_at > ?', Time.zone.now) }
    scope :available, -> { where('start_at <= ? AND (end_at > ? OR end_at IS NULL)', Time.zone.now, Time.zone.now) }
    scope :completed, -> { where('end_at < ?', Time.zone.now) }

    validates :title, presence: true
    validates :start_at, presence: true

    validate(if: -> { start_at.present? && end_at.present? }) do
      errors.add(:end_at, 'must be after the start date') unless end_at > start_at
    end

    validate(if: -> { registration_start_at.present? && registration_end_at.present? }) do
      errors.add(:registration_end_at, 'must be after the registration start date') unless registration_end_at > registration_start_at
    end

    # before_destroy do
    #   if (count = mentorship_groups.length) > 0
    #     raise("#{count} groups belong to this cycle")
    #   end
    # end

    def self.effective_mentorships_mentorship_cycle?
      true
    end

    def self.latest_cycle
      order(id: :desc).first
    end

    def to_s
      title.presence || model_name.human
    end

    # Returns a duplicated event object, or throws an exception
    def duplicate
      MentorshipCycle.new(attributes.except('id', 'updated_at', 'created_at', 'token')).tap do |mentorship|
        mentorship.start_at = mentorship.start_at.advance(years: 1) if mentorship.start_at.present?
        mentorship.end_at = mentorship.end_at.advance(years: 1) if mentorship.end_at.present?
        mentorship.registration_start_at = mentorship.registration_start_at.advance(years: 1) if mentorship.registration_start_at.present?
        mentorship.registration_end_at = mentorship.registration_end_at.advance(years: 1) if mentorship.registration_end_at.present?

        mentorship.title = mentorship.title + ' (Copy)'

        mentorship.rich_texts.each { |rt| self.send("rich_text_#{rt.name}=", rt.body) }
      end
    end

    # def available?
    #   started? && !ended?
    # end

    # def unavailable?
    #   !available?
    # end

    # def started?
    #   start_at.present? && Time.zone.now >= start_at
    # end

    # def ended?
    #   end_at.present? && end_at < Time.zone.now
    # end

    # def available_date
    #   if start_at && end_at
    #     "#{start_at.strftime('%F')} to #{end_at.strftime('%F')}"
    #   elsif start_at
    #     "#{start_at.strftime('%F')}"
    #   end
    # end

  end
end
