class User < ApplicationRecord
  rolify
  has_secure_password
  has_many :roster_spots
  has_many :seasons, -> {order(start: :desc).distinct}, through: :roster_spots
  has_many :patrols
  has_many :substitutes, class_name: 'Substitution', foreign_key: :user_id
  has_many :substitutions, class_name: 'Substitution', foreign_key: :sub_id
  validates :password, length: {minimum: 8}, format: { with: /\A[[:alnum:][:punct:]]{8,72}\z/ }
  validates :name, presence: true

  scope :sub_email_list, -> (ignore_ids, season_id) {
    joins(:seasons).where.not(id: ignore_ids).where('EXISTS (SELECT 1 FROM seasons where id = ?)', season_id).pluck(:email)
  }

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
