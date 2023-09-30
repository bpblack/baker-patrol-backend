class Calendar < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :calendar, polymorphic: true
end
