class PatrolResponsibility < ApplicationRecord
  has_many :patrols
  belongs_to :role
  validates_uniqueness_of :name, scope: :version 
end
