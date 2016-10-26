class RosterSpot < ApplicationRecord
  resourcify
  belongs_to :season
  belongs_to :team
  belongs_to :user
  validates_uniqueness_of :season_id, scope: :user_id

  def team_roles_string
    return roles_str(Rails.application.config.team_roles)
  end

  def team_extra_roles_string
    return roles_str(Rails.application.config.team_extra_roles)
  end

  def team_all_roles_string
    r = team_roles_string
    e = team_extra_roles_string
    e.blank? ? r : "#{r}, #{e}"
  end

  private 
  def roles_str roles_array
    roles = []
    has_roles_method = user.roles.loaded? ? :has_cached_role? : :has_role?
    roles_array.each do |role|
      roles << role[:name] if user.method(has_roles_method).call(role[:role], role[:resourced] ? self : nil)
    end
    roles.join(', ')
  end
end
