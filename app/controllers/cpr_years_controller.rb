class CprYearsController < ApplicationController
  before_action :authenticate_user

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
      @latest = CprYear.create!(year: Date.new(cur))
      render :latest, formats: [:json], status: :ok
    else
      render json: {message: "#{cur} has already been initialized."}, status: :bad_request
    end
  end
end
