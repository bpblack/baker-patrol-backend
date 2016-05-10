class DutyDay < ApplicationRecord
  belongs_to :season
  belongs_to :team
  has_many :patrols
  validates_uniqueness_of :team_id, scope: [:date] 
end
