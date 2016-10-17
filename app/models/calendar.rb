class Calendar < ApplicationRecord
  belongs_to :user
  belongs_to :calendar, polymorphic: true
end
