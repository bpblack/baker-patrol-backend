class CprYear < ApplicationRecord
    def expired?
        Date.today.year > year.year
    end
end
