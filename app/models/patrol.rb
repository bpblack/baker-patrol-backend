class Patrol < ApplicationRecord
  belongs_to :user
  belongs_to :duty_day
  belongs_to :patrol_responsibility
  has_many :substitutions, -> { order(id: :desc) }
  has_one :latest_substitution, -> { order(id: :desc) }, class_name: 'Substitution'
  validates_uniqueness_of :user_id, scope: :duty_day_id
  validates_uniqueness_of :patrol_responsibility_id, scope: :duty_day_id
  scope :duty_day_team_responsibility, -> (user_id, season_id) {
    includes({duty_day: :team}, :patrol_responsibility, {latest_substitution: :sub}).where(user_id: user_id, duty_days: {season_id: season_id}).merge(DutyDay.order(date: :asc)) 
  }
  scope :duty_day_team_responsibility_subs, -> (patrol_id) {
    includes({duty_day: :team}, {substitutions: [:user, :sub]}, :patrol_responsibility).find(patrol_id)
  }
  scope :season_duty_days_ordered, -> (season_id) {
    joins(:duty_day).includes(:patrol_responsibility).where(duty_days: {season_id: season_id}).order('duty_days.date ASC')
  }
  
end
