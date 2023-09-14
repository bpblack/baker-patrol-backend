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
    sep = r.blank? ? '' : ', '
    e.blank? ? r : "#{r}#{sep}#{e}"
  end

  private 
  def roles_str roles_array
    roles = []
    user.roles.load_target unless user.roles.loaded?
    roles_array.each do |role|
      roles << role[:name] if user.has_cached_role?(role[:role], role[:resourced] ? self : nil)
    end
    roles.join(', ')
  end
end
