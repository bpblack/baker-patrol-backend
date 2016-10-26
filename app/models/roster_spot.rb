class RosterSpot < ApplicationRecord
  resourcify
  belongs_to :season
  belongs_to :team
  belongs_to :user
  validates_uniqueness_of :season_id, scope: :user_id

  def team_roles_string
    roles = []
    has_roles_method = user.roles.loaded? ? :has_cached_role? : :has_role?
    Rails.application.config.team_roles.each do |role|
      roles << role[:name] if user.method(has_roles_method).call(role[:role], role[:resourced] ? self : nil)
    end
    roles.join(', ')
  end

  def team_extra_roles_string
    roles = []
    Rails.application.config.team_extra_roles do |role|
      roles << role[:name] if user.method(has_roles_method).call(role[:role], role[:resourced] ? self : nil)
    end
    roles.join(', ')
  end

  def team_all_roles_string
    r = team_roles_string
    e = team_extra_roles_string
    e.blank? ? r : "#{r}, #{e}"
  end
end
