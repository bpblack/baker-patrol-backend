class PatrolResponsibility < ApplicationRecord
  has_many :patrols
  validates_uniqueness_of :name, scope: :version 
end
