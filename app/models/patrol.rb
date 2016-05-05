class Patrol < ApplicationRecord
  belongs_to :user#, -> { 
  #  joins(:duty_day, :patrol_responsibility).
  #    select('patrols.id,' \
  #           'patrols.duty_day_id,'\
  #           'duty_days.date,'\
  #           'duty_days.season_id,'\
  #           'patrols.patrol_responsibility_id,'\
  #           'patrol_responsibilities.name AS responsibility_name,'\
  #           'patrol_responsibilities.version AS responsibility_version,'\
  #           '(case when duty_days.date < current_date then false else true end) as swappable')
  #}
  belongs_to :duty_day
  belongs_to :patrol_responsibility
  has_many :substitutions
  validates_uniqueness_of :user_id, scope: :duty_day_id
  validates_uniqueness_of :patrol_responsibility_id, scope: :duty_day_id
end
