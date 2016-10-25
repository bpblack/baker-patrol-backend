class Patrol < ApplicationRecord
  attr_accessor :skip_responsibility_validation
  after_initialize :initialize_skip_responsibility_validation
  
  belongs_to :user
  belongs_to :duty_day
  belongs_to :patrol_responsibility, optional: :skip_responsibility_validation
  has_many :substitutions, -> { order(id: :desc) }
  has_one :latest_substitution, -> { includes(:sub).order(id: :desc) }, class_name: 'Substitution'
  has_many :calendar_events
  has_one :google_event, -> { where(owner_type: 'GoogleCalendar') }, class_name: 'CalendarEvent'

  validates_uniqueness_of :user_id, scope: :duty_day_id
  validates_uniqueness_of :patrol_responsibility_id, scope: :duty_day_id, unless: :skip_responsibility_validation
  validate :user_has_responsibility_role, unless: Proc.new { |p| p.skip_responsibility_validation and p.patrol_responsibility.nil? }

  scope :duty_day_team_responsibility, -> (user_id, season_id) {
    includes({duty_day: :team}, :patrol_responsibility).where(user_id: user_id, duty_days: {season_id: season_id}).merge(DutyDay.order(date: :asc)) 
  }

  scope :duty_day_team_responsibility_subs, -> (patrol_id) {
    includes({duty_day: :team}, {substitutions: [:user, :sub]}, :patrol_responsibility).find(patrol_id)
  }

  scope :season_duty_days_ordered, -> (season_id) {
    joins(:duty_day).includes(:patrol_responsibility).where(duty_days: {season_id: season_id}).order('duty_days.date ASC')
  }
  

  private
  def initialize_skip_responsibility_validation
    @skip_responsibility_validation = false
  end

  def user_has_responsibility_role
    responsibility_role_name =  patrol_responsibility.role.name
    unless user.has_role?(responsibility_role_name.to_sym, user.season_roster_spot(patrol.duty_day.season_id))
      error_role_string = %w(a e i o u).include?(responsibility_role_name.downcase) ? "an #{responsibility_role_name}" : "a #{responsibility_role_name}"
      errors.add(:responsibility_role, "Cannot give #{user.name} #{error_role_string} responsibility.") 
    end
  end
end
