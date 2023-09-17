class CprClass < ActiveRecord::Base
  has_many :students, class_name: "Student"
  belongs_to :classroom, class_name: "Classroom"
  validates :time, presence: true, uniqueness: true

  def time_str 
    time.strftime('%A, %B %d, %Y at %l:%M %p')
  end

  def time_location_str
    time_str + " @ #{classroom.name}"
  end

  def time_enrollment_str
    time_location_str + " (Current Enrollment: #{students.count}/#{class_size})"
  end
end
