class DutyDay < ApplicationRecord
  belongs_to :season
  belongs_to :team
  has_many :patrols
  validates_uniqueness_of :team_id, scope: [:date] 

  def ignores
    ret = []
    patrols.each do |p|
      ret.push p.user.id
      unless p.latest_substitution.nil? || p.latest_substitution.accepted || p.latest_substitution.sub.nil?
        ret.push p.latest_substitution.sub_id
      end
    end
    return ret
  end
end
