module Admin
  class MentorshipGroupUsersController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)
    before_action { EffectiveResources.authorize!(self, :admin, :effective_mentorships) }

    include Effective::CrudController

    resource_scope -> { Effective::MentorshipGroupUser.deep.all }

    private

    def permitted_params
      params.require(:effective_mentorship_group_user).permit!
    end

  end
end
