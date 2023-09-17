#require 'valid_email'
class Student < ActiveRecord::Base
  belongs_to :cpr_class, class_name: "CprClass", counter_cache: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates_uniqueness_of :first_name, scope: :last_name, message: lambda { |x, y| "Student already exists." } 
  #validates :email, presence: true, email: {mx: true, message: I18n.t('validations.errors.models.user.invalid_email')}
  validates :email_sent, inclusion: [true, false]

  def name
    "#{first_name} #{last_name}"
  end
end
