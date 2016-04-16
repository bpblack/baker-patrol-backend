class RosterSpot < ApplicationRecord
  belongs_to :season
  belongs_to :team
  belongs_to :user
  validates_uniqueness_of :season_id, scope: :user_id
end
