module Admin
  class MentorshipCyclesController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)
    before_action { EffectiveResources.authorize!(self, :admin, :effective_mentorships) }

    include Effective::CrudController

    resource_scope -> { Effective::MentorshipCycle.deep.all }

    private

    def permitted_params
      params.require(:effective_mentorship_cycle).permit!
    end

  end
end
