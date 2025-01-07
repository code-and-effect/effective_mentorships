module Admin
  class MentorshipBulkGroupsController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)
    before_action { EffectiveResources.authorize!(self, :admin, :effective_mentorships) }

    include Effective::WizardController

    resource_scope -> { EffectiveMentorships.MentorshipBulkGroup.deep.all }
    datatable -> { EffectiveResources.best('Admin::EffectiveMentorshipBulkGroupsDatatable').new }

    def build_wizard_resource
      resource_scope.new(current_user: current_user)
    end

  end
end
