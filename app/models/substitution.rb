class Substitution < ApplicationRecord
  attr_writer :only_authorize_admin
  after_initialize :initialize_only_authorize_admin
  
  belongs_to :patrol
  belongs_to :user, class_name: 'User', optional: true
  belongs_to :sub, class_name: 'User', optional: true

  validates :patrol, presence: true
  validate  :patrol_date_cannot_be_in_past
  validate  :sub_is_not_patrolling_on_same_duty_day
  validate  :sub_is_active_for_duty_day_season
  validate  :sub_is_not_assigned_on_same_duty_day, if: Proc.new { |sub| sub.sub_id_changed? }
  #validates_uniqueness_of :patrol_id, scope: :user_id
  validate  :patrol_has_no_existing_open_subs, on: :create

  before_destroy :substitution_completed?
  before_update :substitution_completed?

  scope :user_subs, -> (user_id, season_id, is_sub:, accepted: nil, since: nil, future: nil) {
    where_conds = {user_id: user_id}
    if is_sub
      incs = :user
      where_sql = 'substitutions.sub_id = :user_id'
    else
      incs = :sub
      where_sql = 'substitutions.user_id = :user_id'
    end
    # assignable will be nil, true, or false, nil => no conditions, true => not accepted
    case accepted
    when true, false 
      where_conds[:accepted] = accepted
      where_sql += ' AND substitutions.accepted = :accepted'
    else
      #do nothing
    end
    case future
    when true, false
      where_conds[:today] = Time.zone.today
      where_sql += future ? ' AND duty_days.date >= :today' : ' AND duty_days.date < :today'
    else
      #do nothing
    end
    unless since.nil?
      where_sql += ' AND substitutions.updated_at > :since'
      where_conds[:since] = since
    end
    includes(incs).joins(:patrol).merge(Patrol.season_duty_days_ordered(season_id)).select('substitutions.*, duty_days.date, duty_days.id as duty_day_id').where(where_sql, where_conds)
  }

  scope :duty_day_latest_subs, -> (duty_day_id, since: nil) {
    where_sql = 's2.id IS NULL'
    where_conds = {}
    if since
      where_sql += ' AND substitutions.updated_at > :since'
      where_conds[:since] = since
    end
    joins("LEFT JOIN substitutions AS s2 ON (substitutions.patrol_id = s2.patrol_id AND substitutions.id < s2.id)").joins(:patrol).where(where_sql, where_conds).where(patrols: {duty_day_id: duty_day_id})
  }

  def completed?
    # any changes after accepted, accepted was changed but was already true, date is in the past
    (!accepted_changed? && accepted) || (accepted_changed? && accepted_change[0]) || patrol.duty_day.date < Time.zone.today
  end

  def only_authorize_admin?
    @only_authorize_admin
  end
  
  private

  def patrol_date_cannot_be_in_past
    if patrol.duty_day.date < Time.zone.today
      errors.add(:substitution_date, 'Cannot create substitituion request for a duty day that has already occured.')
    end
  end

  def sub_is_not_patrolling_on_same_duty_day
    if patrol.duty_day.patrols.exists?(['user_id = ?', sub_id])
      errors.add(:sub_already_patrolling, 'Cannot add a substitute patroller who already is patrolling on the given duty day.')
    end
  end

  def sub_is_not_assigned_on_same_duty_day
    if patrol.duty_day.patrols.includes(:latest_substitution).exists?(['substitutions.accepted = false AND substitutions.sub_id = ?', sub_id])
      errors.add(:sub_already_assigned, 'Cannot add a substitute patroller who is alreay assigned to any open substitution request on the given duty day.')
    end
  end

  def sub_is_active_for_duty_day_season
    unless sub.nil? || sub.roster_spots.exists?(['season_id = ?', patrol.duty_day.season_id])
      errors.add(:inactive_sub, "Cannot add a substitute patroller who is not active for the duty day's season")
    end
  end

  def patrol_has_no_existing_open_subs
    if patrol.substitutions.exists?(['accepted = ?', false])
      errors.add(:open_request, 'Cannot add a sub request to a patrol that already has an open request')
    end
  end

  def substitution_completed?
    if completed?
      errors.add(:substitution_final, 'Substitution is alreay accepted or in the past') 
      throw :abort
    end
  end

  def initialize_only_authorize_admin
    @only_authorize_admin = false
  end
end

