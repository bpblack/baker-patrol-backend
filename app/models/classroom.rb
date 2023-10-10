class Classroom < ActiveRecord::Base
  has_many :cpr_classes, class_name: "CprClass"
  validates :name, presence: true, uniqueness: true
  validates :address, presence: true, uniqueness: true
  validates :map_link, presence: true
end
