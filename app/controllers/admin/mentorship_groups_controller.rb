module Admin
  class MentorshipGroupsController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)
    before_action { EffectiveResources.authorize!(self, :admin, :effective_mentorships) }

    include Effective::CrudController

    resource_scope -> { EffectiveMentorships.MentorshipGroup.deep.all }
    datatable -> { EffectiveResources.best('Admin::EffectiveMentorshipGroupsDatatable').new }

    private

    def permitted_params
      model = (params.key?(:effective_mentorship_group) ? :effective_mentorship_group : :mentorship_group)
      params.require(model).permit!
    end
  end
end
