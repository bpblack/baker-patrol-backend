class Team < ApplicationRecord
  has_many :roster_spots
  has_many :duty_days
  validates_uniqueness_of :name

  scope :season_roster_spots, -> (season_id) {
    includes({roster_spots: :user}).where(roster_spots: {season_id: season_id})
  }

  def leader
    @leader = roster_spots.find { |rs| rs.leader? } unless @leader
    @leader
  end
end
