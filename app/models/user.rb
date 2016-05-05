class User < ApplicationRecord
  has_secure_password
  has_many :roster_spots
  has_many :teams, through: :roster_spots
  has_many :patrols#, -> { 
  #  joins(:duty_day, :patrol_responsibility).
  #    select('patrols.id,'\
  #           'duty_days.date,'\
  #           'duty_days.season_id,'\
  #           'patrols.patrol_responsibility_id,'\
  #           'patrol_responsibilities.name,'\
  #           'patrol_responsibilities.version,'\
  #           '(case when duty_days.date < current_date then false else true end) as swappable') 
  #}
  validates :password, length: {minimum: 8}, format: { with: /\A[[:alnum:][:punct:]]{8,72}\z/ }
  validates :name, presence: true

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!(validate: false)
    UserMailer.password_reset(self).deliver
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end
end
