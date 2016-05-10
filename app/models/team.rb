class Team < ApplicationRecord
  has_many :roster_spots
  has_many :duty_days
  validates_uniqueness_of :name

  def leader
    @leader = roster_spots.find { |rs| rs.leader? } unless @leader
    @leader
  end
end
