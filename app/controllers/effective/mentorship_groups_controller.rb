module Effective
  class MentorshipGroupsController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)

    include Effective::CrudController

    resource_scope -> { EffectiveMentorships.MentorshipGroup.deep.all }
  end
end
