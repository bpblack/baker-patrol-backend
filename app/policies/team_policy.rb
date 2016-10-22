class TeamPolicy < ApplicationPolicy
  def index?
    #only authorize when getting all teams for a season (i.e. roster)
    user.has_role?(:admin)
  end
end
