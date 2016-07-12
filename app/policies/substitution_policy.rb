class SubstitutionPolicy < ApplicationPolicy
  def index?
    allow = false
    unless record.user_id.nil?
      allow = (user.id == record.user_id or user.has_role?(:admin))
    end
    unless record.patrol.nil?
      allow = (user.has_role?(:admin) or user.has_role?(:leader, user.roster_spots.where(season_id: record.patrol.duty_day.season_id, team_id: record.patrol.duty_day.team_id).first))
    end
    allow
  end

  def create?
    user.id == record.user_id or user.has_role?(:admin)
  end

  def update?
    user.id == record.user_id or user.id == record.sub_id or user.has_role?(:admin)
  end

  def destroy?
    not record.accepted and record.patrol.duty_day.date > Date.today and (user.id == record.user_id or user.has_role?(:admin))
  end

end
