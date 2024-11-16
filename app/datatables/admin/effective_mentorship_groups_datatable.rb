module Admin
  class EffectiveMentorshipGroupsDatatable < Effective::Datatable
    filters do
      scope :all
      scope :archived
    end

    datatable do
      order :updated_at

      col :updated_at, visible: false
      col :created_at, visible: false
      col :id, visible: false
      col :token, visible: false

      col :mentorship_cycle
      col :title
      col :rich_text_admin_notes, label: "Admin notes"

      col :mentorship_group_users, search: :string do |mentorship_group|
        mentorship_group.mentorship_group_users.map do |mentorship_group_user| 
          content_tag(:div, class: 'col-resource_item') do
            mentorship_role_badge(mentorship_group_user.mentorship_role) + ' ' + mentorship_group_user.name
          end
        end.join.html_safe
      end

      col :archived

      actions_col
    end

    collection do
      EffectiveMentorships.MentorshipGroup.deep.all
    end
  end
end
