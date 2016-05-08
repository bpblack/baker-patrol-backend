class Patrol < ApplicationRecord
  belongs_to :user
  belongs_to :duty_day
  belongs_to :patrol_responsibility
  has_many :substitutions
  validates_uniqueness_of :user_id, scope: :duty_day_id
  validates_uniqueness_of :patrol_responsibility_id, scope: :duty_day_id
end
