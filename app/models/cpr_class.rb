class CprClass < ActiveRecord::Base
  has_many :students, class_name: "CprStudent"
  belongs_to :classroom, class_name: "Classroom"
  validates :time, presence: true, uniqueness: { scope: :classroom_id }
  validates_numericality_of :class_size, greater_than_or_equal_to: :students_count

  def self.skip_time_zone_conversion_for_attributes
    [:time]
  end

  def time_str 
    time.strftime('%a %m/%d/%Y %I:%M %p')
  end

  def sorted_students
    return @sorted_students if @sorted_students
    @sorted_students = students.sort_by {|s| s.student.last_name + s.student.first_name}
  end
end
