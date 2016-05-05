class DutyDay < ApplicationRecord
  belongs_to :season
  belongs_to :team
  has_many :patrols
  has_many :users
  validates_uniqueness_of :team_id, scope: [:date] 
end
