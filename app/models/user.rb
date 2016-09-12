class User < ApplicationRecord
  rolify
  has_secure_password
  has_many :roster_spots
  has_many :seasons, -> {order(start: :desc).distinct}, through: :roster_spots
  has_many :patrols
  has_many :substitutes, class_name: 'Substitution', foreign_key: :user_id
  has_many :substitutions, class_name: 'Substitution', foreign_key: :sub_id
  validates :password, length: {minimum: 8}, format: { with: /\A[[:alnum:][:punct:]]{8,72}\z/ }
  validates :first_name, presence: true
  validates :last_name, presence: true

  scope :subables, -> (ignore_ids, season_id, role_id) {
    joins(:seasons, :roles).where.not(id: ignore_ids).where('EXISTS (SELECT 1 FROM seasons where id = ?) AND EXISTS (SELECT 1 FROM roles WHERE role_id = ?)', season_id, role_id)
  }

  def name
    "#{self.first_name} #{self.last_name}"
  end

  def send_password_reset
    generate_token(:password_reset_token)
    self.password_reset_sent_at = Time.zone.now
    save!(validate: false)
    UserMailer.password_reset(self).deliver_later
  end

  def generate_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end
  
  def self.from_token_payload payload
    self.find(payload["sub"])
  end

end
