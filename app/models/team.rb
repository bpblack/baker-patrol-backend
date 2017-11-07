class Team < ApplicationRecord
  attr_accessor :roster_season_id
  has_many :roster_spots
  has_many :duty_days
  validates_uniqueness_of :name

  scope :season_roster_spots, -> (season_id:, preload: false) {
    user_inc = (preload) ? {user: :roles} : :user
    includes({roster_spots: user_inc}).where(roster_spots: {season_id: season_id}).order('roster_spots.id')
  }

  # new data is added so infrequently that caching in member var *should* be ok
  def leader(season_id)
    @leader = roster_spots.where(season_id: season_id).find do |rs| 
      user = rs.user  
      user.method(user.roles.loaded? ? :has_cached_role? : :has_role?).call(:leader, rs) 
    end unless @leader
    @leader
  end

  def sorted_members
    return @sorted_users if @sorted_users
    comparator = lambda do |rs|
      has_role_method = rs.user.roles.loaded? ? :has_cached_role? : :has_role?
      Rails.application.config.team_role_ranks.each do |rr|
        if rs.user.method(has_role_method).call(rr[:role], rr[:resourced] ? rs : nil)
          return rr[:rank].to_s + rs.user.last_name
        end
      end
    end
    @sorted_users = roster_spots.sort_by { |x| comparator.call(x) }
  end
end
