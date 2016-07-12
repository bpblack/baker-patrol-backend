class Season < ApplicationRecord
  has_many :roster_spots
  has_many :duty_days
  validates_uniqueness_of :name

  def self.current_season_id
    order(start: :desc).pluck(:id).first
  end
end
