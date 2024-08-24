class CprStudent < ApplicationRecord
  belongs_to :cpr_class
  belongs_to :cpr_year
  belongs_to :student, polymorphic: true
end
