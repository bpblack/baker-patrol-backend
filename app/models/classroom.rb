class Classroom < ActiveRecord::Base
  has_many :cpr_classes, class_name: "CprClass"
end
