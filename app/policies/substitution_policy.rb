class SubstitutionPolicy < ApplicationPolicy
  def index?
    # model is a dummy created only for authorization
    allow = false
    unless record.user_id.nil?
      allow = (user.id == record.user_id or user.has_role?(:admin))
    end
    unless record.patrol.nil?
      allow = user_is_admin_or_duty_day_team_leader? || user_is_staff?
    end
    allow
  end

  def create?
    (!record.only_authorize_admin? && user.id == record.user_id) or user_is_admin_or_duty_day_team_leader?
  end

  def assign?
    (!record.only_authorize_admin? && user.id == record.user_id) or user_is_admin_or_duty_day_team_leader?
  end

  def accept?
    user.id == record.sub_id
  end

  def reject?
    user.id == record.sub_id
  end
  
  def remind?
    user.id == record.user_id or user_is_admin_or_duty_day_team_leader?
  end

  def destroy?
    user.id == record.user_id or user_is_admin_or_duty_day_team_leader?
  end

  def assignable?
    user.id == record.user_id or user_is_admin_or_duty_day_team_leader?
  end

  def user_is_admin_or_duty_day_team_leader?
    user.has_role?(:admin) or user.has_role?(:leader, user.roster_spots.find_by(season_id: record.patrol.duty_day.season_id, team_id: record.patrol.duty_day.team_id))
  end

  def user_is_staff?
    user.has_role?(:staff, user.roster_spots.find_by(season_id: record.patrol.duty_day.season_id))
  end
end
