module Effective
  class MentorshipsMailer < EffectiveMentorships.parent_mailer_class

    include EffectiveMailer
    include EffectiveEmailTemplatesMailer

    def mentorship_group_created_to_mentor(resource, opts = {})
      raise('expected an Effective::MentorshipGroupUser') unless resource.kind_of?(Effective::MentorshipGroupUser)
      raise('expected a mentor') unless resource.mentor?

      @assigns = assigns_for(resource).merge(url: effective_mentorships.mentorship_group_url(resource))
      mail(to: resource.user.email, **headers_for(resource, opts))
    end

    def mentorship_group_created_to_mentee(resource, opts = {})
      raise('expected an Effective::MentorshipGroupUser') unless resource.kind_of?(Effective::MentorshipGroupUser)
      raise('expected a mentee') unless resource.mentee?

      @assigns = assigns_for(resource).merge(url: effective_mentorships.mentorship_group_url(resource))
      mail(to: resource.user.email, **headers_for(resource, opts))
    end

    protected

    def assigns_for(resource)
      unless resource.kind_of?(Effective::MentorshipGroupUser)
        raise('expected an Effective.MentorshipGroupUser')
      end
      
      @mentorship_group_user = resource

      @user = resource.user
      @mentorship_group = resource.mentorship_group
      @mentorship_cycle = resource.mentorship_group.mentorship_cycle

      {
        user: { 
          name: @user.to_s,
          first_name: @user.try(:first_name),
          last_name: @user.try(:last_name),
          email: @user.try(:email),
          mentorship_role: @mentorship_group_user.mentorship_role
        },
        group: {
          title: @mentorship_group.to_s,
          mentor_names: @mentorship_group.mentors.map(&:to_s).join(', '),
          mentor_emails: @mentorship_group.mentors.map(&:email).join(', '),
          mentee_names: @mentorship_group.mentees.map(&:to_s).join(', '),
          mentee_emails: @mentorship_group.mentees.map(&:email).join(', '),
        }
      }
    end

  end
end
