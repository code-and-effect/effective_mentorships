module Admin
  class EffectiveMentorshipGroupsDatatable < Effective::Datatable
    filters do
      scope :all
      scope :published
      scope :draft
    end

    datatable do
      order :updated_at

      col :updated_at, visible: false
      col :created_at, visible: false
      col :id, visible: false
      col :token, visible: false

      col :mentorship_bulk_group, visible: false
      col :mentorship_cycle, visible: attributes[:mentorship_bulk_group_id].blank?

      col :published?, as: :boolean
      col :published_start_at, label: "Published start", visible: false
      col :published_end_at, label: "Published end", visible: false

      col :title

      col(:mentorship_group_mentors, label: mentorships_mentors_label) do |mentorship_group|
        mentorship_group.mentorship_group_mentors.map do |mentorship_group_user| 
          user = mentorship_group_user.user
          registration = mentorship_group_user.mentorship_registration

          content_tag(:div, class: 'col-resource_item') do
            [
              content_tag(:div) { link_to(user, "/admin/users/#{user.to_param}/edit") },
              (content_tag(:div, content_tag(:small, registration.details)) if registration.present?)
            ].compact.join.html_safe
          end
        end.join.html_safe
      end

      #col :mentorship_group_mentors, label: mentorships_mentors_label
      #col :mentorship_group_mentees, label: mentorships_mentees_label

      col(:mentorship_group_mentees, label: mentorships_mentees_label) do |mentorship_group|
        mentorship_group.mentorship_group_mentees.map do |mentorship_group_user| 
          user = mentorship_group_user.user
          registration = mentorship_group_user.mentorship_registration

          content_tag(:div, class: 'col-resource_item') do
            [
              content_tag(:div) { link_to(user, "/admin/users/#{user.to_param}/edit") },
              (content_tag(:div, content_tag(:small, registration.details)) if registration.present?)
            ].compact.join.html_safe
          end
        end.join.html_safe
      end

      col :rich_text_admin_notes, label: "Admin notes"

      col :last_notified_at, as: :date do |mentorship_group|
        mentorship_group.last_notified_at&.strftime('%F') || '-'
      end

      actions_col
    end

    collection do
      EffectiveMentorships.MentorshipGroup.deep.all
    end
  end
end
