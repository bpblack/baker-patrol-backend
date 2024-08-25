class CprStudent < ApplicationRecord
  belongs_to :cpr_class, optional: true
  belongs_to :cpr_year
  belongs_to :student, polymorphic: true

  def generate_token()
    begin
      self[:email_token] = SecureRandom.urlsafe_base64
    end while CprStudent.exists?(email_token: self[:email_token])
  end

  def modifiable()
    return self.student_type != 'User'
  end 
end