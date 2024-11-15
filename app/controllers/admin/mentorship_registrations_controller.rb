module Admin
  class MentorshipRegistrationsController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)
    before_action { EffectiveResources.authorize!(self, :admin, :effective_mentorships) }

    include Effective::CrudController

    resource_scope -> { EffectiveMentorships.MentorshipRegistration.deep.all }
    datatable -> { EffectiveResources.best('Admin::EffectiveMentorshipRegistrationsDatatable').new }

    private

    def permitted_params
      model = (params.key?(:effective_mentorship_registration) ? :effective_mentorship_registration : :mentorship_registration)
      params.require(model).permit!
    end

  end
end
