class DutyDayPolicy < ApplicationPolicy
  def index?
    user.has_role?(:admin) || user_is_leader_or_staff?
  end

  def user_is_leader_or_staff?
    user.has_role?(:leader, user.roster_spots.find_by(season_id: record.season_id)) || user.has_role?(:staff, user.roster_spots.find_by(season_id: record.season_id))
  end
end

