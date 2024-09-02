class CprYearsController < ApplicationController
  before_action :authenticate_user
  rescue_from ActiveRecord::ActiveRecordError, with: :cpr_year_invalid

  def latest
    authorize CprYear
    @latest = CprYear.last
    if @latest
      render formats: [:json], status: :ok
    else
      render json: nil, status: :ok
    end
  end

  def index
    authorize CprYear
    @years = CprYear.all
    render formats: [:json], status: :ok
  end

  def create
    authorize CprYear
    cur = Date.today.year
    last = CprYear.last
    if !last || cur > last.year.year
      # create the cpr year and load patrol students automatically
      @latest = CprYear.create!(year: Date.new(cur))
      patrolStudents = User.joins(:roster_spots).merge(RosterSpot.where(season_id: Season.last.id)).
        joins("INNER JOIN users_roles ON users_roles.user_id = users.id INNER JOIN roles ON roles.id = users_roles.role_id AND roles.resource_id = roster_spots.id").
        where("roles.name in ('oec', 'onhill')")
      patrolStudents.each do |s|
        c = CprStudent.new(cpr_year: @latest, student: s, email_sent: false, has_cpr_cert: false)
        c.generate_token()
        c.save!
      end
      render :latest, formats: [:json], status: :ok
    else
      render json: "#{cur} has already been initialized.", status: :bad_request
    end
  end

  private

  def cpr_year_invalid(exception)
    render json: exception.message, status: :bad_request 
  end
end
