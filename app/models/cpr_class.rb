class CprClass < ActiveRecord::Base
  has_many :students, class_name: "Student"
  belongs_to :classroom, class_name: "Classroom"
  validates :time, presence: true, uniqueness: true

  def self.skip_time_zone_conversion_for_attributes
    [:time]
  end

  def time_str 
    time.strftime('%a %m/%d/%Y %I:%M %p')
  end

  def sorted_students
    return @sorted_students if @sorted_students
    @sorted_students = students.sort_by {|s| s.last_name + s.first_name}
  end
end
