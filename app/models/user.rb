class User < ApplicationRecord
  attr_writer :password_validation
  after_initialize :initialize_password_validation

  rolify
  has_secure_password validations: :password_validation?
  has_many :roster_spots
  has_many :seasons, -> {order(start: :desc).distinct}, through: :roster_spots
  has_many :patrols
  has_many :substitutes, class_name: 'Substitution', foreign_key: :user_id
  has_many :substitutions, class_name: 'Substitution', foreign_key: :sub_id
  has_many :calendars
  has_one  :google_calendar_relation, -> { where(calendar_type: 'GoogleCalendar') }, class_name: 'Calendar'
  has_one  :google_calendar, through: :google_calendar_relation, source: :calendar, source_type: 'GoogleCalendar' 
  validates :password, length: {minimum: 8}, format: { with: /\A[[:alnum:][:punct:]]{8,72}\z/ }, if: :password_validation?
  validates :first_name, presence: true
  validates :last_name, presence: true

  scope :subables, -> (ignore_ids, season_id, role_sym) {
    #joins(:seasons, :roles).where.not(id: ignore_ids).where('EXISTS (SELECT 1 FROM seasons where id = ?) AND EXISTS (SELECT 1 FROM roles WHERE role_name LIKE ?)', season_id, role_sym)
    joins(:roster_spots).merge(RosterSpot.where(season_id: season_id)).
    joins(:roles).merge(Role.where(name: role_sym)).
    where.not(id: ignore_ids).where('EXISTS (SELECT 1 FROM roles WHERE resource_id=roster_spots.id)').
    order(:last_name)
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

  def season_roster_spot(season_id)
    roster_spots.find_by(season_id: season_id)
  end

  def self.from_token_payload payload
    self.find(payload["sub"])
  end

  private
  def initialize_password_validation
    @password_validation = true
  end

  def password_validation?
    @password_validation
  end
end
