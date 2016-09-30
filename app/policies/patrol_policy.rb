class PatrolPolicy < ApplicationPolicy
  def index?
    true
  end

  def assignable?
    true
  end

  #only admins or team leads can swap duties
  def swap?
    user.has_role?(:admin) or user.has_role?(:leader, user.roster_spots.find_by(season_id: record.duty_day.season_id, team_id: record.duty_day.team_id))
  end
end
