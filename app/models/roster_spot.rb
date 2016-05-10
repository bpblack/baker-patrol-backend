class RosterSpot < ApplicationRecord
  resourcify
  belongs_to :season
  belongs_to :team
  belongs_to :user
  validates_uniqueness_of :season_id, scope: :user_id

  def leader?
    @leader = user.has_role?(:leader, self) unless @leader
    @leader
  end
    
end
