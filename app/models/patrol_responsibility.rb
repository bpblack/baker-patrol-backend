class PatrolResponsibility < ApplicationRecord
  has_many :patrols
  belongs_to :role
  validates_uniqueness_of :name, scope: :version 
  
  def versioned_name
    "#{name} v#{version}"
  end
end
