class TeamPolicy < ApplicationPolicy
  def index?
    #only authorize when getting all teams for a season (i.e. roster)
    user.has_role?(:admin) || user_is_leader_or_staff?
  end

  def user_is_leader_or_staff?
    return user.has_role?(:leader, user.roster_spots.find_by(season_id: record.roster_season_id)) || user.has_role?(:staff, user.roster_spots.find_by(season_id: record.roster_season_id))
  end
end
