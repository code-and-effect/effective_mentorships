module Effective
  class MentorshipCyclesController < ApplicationController
    before_action(:authenticate_user!) if defined?(Devise)

    include Effective::CrudController

    resource_scope -> { Effective::MentorshipCycle.deep.all }
  end
end
