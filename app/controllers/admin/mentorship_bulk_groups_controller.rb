module Admin
  class MentorshipBulkGroupsController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)
    before_action { EffectiveResources.authorize!(self, :admin, :effective_mentorships) }

    include Effective::WizardController

    resource_scope -> { EffectiveMentorships.MentorshipBulkGroup.deep.all }
    datatable -> { EffectiveResources.best('Admin::EffectiveMentorshipBulkGroupsDatatable').new }

    private

    def permitted_params
      model = (params.key?(:effective_mentorship_bulk_group) ? :effective_mentorship_bulk_group : :mentorship_bulk_group)
      params.require(model).permit!
    end

  end
end
