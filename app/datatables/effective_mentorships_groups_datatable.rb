# Dashboard - My mentorship groups
class EffectiveMentorshipsGroupsDatatable < Effective::Datatable
  datatable do
    order :mentorship_cycle

    col :mentorship_cycle
    col :title

    col :mentorship_group_users, search: :string do |mentorship_group|
      mentorship_group.mentorship_group_users.map do |mentorship_group_user| 
        user = mentorship_group_user.user

        content_tag(:div, class: 'col-resource_item') do
          mentorship_role_badge(mentorship_group_user.mentorship_role) + ' ' + link_to(user, "mailto:#{user.try(:public_email).presence || user.email}")
        end
      end.join.html_safe
    end

    actions_col
  end

  collection do
    EffectiveMentorships.MentorshipGroup.deep.unarchived.where(id: current_user.mentorship_groups)
  end
end
