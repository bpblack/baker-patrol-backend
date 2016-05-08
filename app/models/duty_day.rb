class DutyDay < ApplicationRecord
  belongs_to :season
  belongs_to :team
  has_many :patrols
  has_many :users, -> {
    joins('INNER JOIN patrol_responsibilities on patrols.patrol_responsibility_id = patrol_responsibilities.id')
    .select(
      'users.id,'\
      'users.name,'\
      'patrols.patrol_responsibility_id,'\
      'patrol_responsibilities.name AS responsibility_name,'\
      'patrol_responsibilities.version AS responsibility_version',
    )
    .order(:name)
  }, through: :patrols
  validates_uniqueness_of :team_id, scope: [:date] 
end
