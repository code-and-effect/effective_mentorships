module Effective
  class MentorshipsMailer < EffectiveMentorships.parent_mailer_class

    include EffectiveMailer
    include EffectiveEmailTemplatesMailer

    protected

    def assigns_for(resource)
      unless resource.kind_of?(EffectiveMentorships.MentorshipGroup)
        raise('expected an EffectiveMentorships.MentorshipGroup')
      end

      {}
    end

  end
end
