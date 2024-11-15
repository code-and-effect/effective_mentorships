module Effective
  class MentorshipRegistrationsController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)

    include Effective::CrudController

    resource_scope -> { EffectiveMentorships.MentorshipRegistration.deep.all }

    resource_scope do
      cycle = Effective::MentorshipCycle.find(params[:mentorship_cycle_id])
      EffectiveMentorships.MentorshipRegistration.deep.where(mentorship_cycle: cycle)
    end
  end
end
