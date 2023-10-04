#require 'valid_email'
class Student < ActiveRecord::Base
  belongs_to :cpr_class, class_name: "CprClass", counter_cache: true, optional: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates_uniqueness_of :first_name, scope: :last_name, message: lambda { |x, y| "Student already exists." } 
  validates :email, email: true
  validates :email_sent, inclusion: [true, false]

  def name
    "#{first_name} #{last_name}"
  end
end
