class Team < ApplicationRecord
  has_many :roster_spots
  has_many :duty_days
  validates_uniqueness_of :name
end
