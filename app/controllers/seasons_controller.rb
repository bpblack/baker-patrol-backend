class SeasonsController < ApplicationController
  require 'JSON'
  require 'CSV'
  include BakerDataService
  before_action :authenticate_user
  rescue_from ActiveRecord::ActiveRecordError, with: :season_invalid
  rescue_from IOError, with: :season_invalid
  rescue_from SystemCallError, with: :season_invalid
  rescue_from JSON::JSONError, with: :season_invalid
  rescue_from CSV::MalformedCSVError, with: :season_invalid
  rescue_from CSV::Parser::InvalidEncoding, with: :season_invalid
  rescue_from CSV::Parser::UnexpectedError, with: :season_invalid

  def latest 
    authorize Season
    @latest = Season.last
    render formats: [:json], status: :ok
  end

  def create
    authorize Season
    sd = DateTime.parse(params[:start]).to_date
    ed = DateTime.parse(params[:end]).to_date
    season = BakerDataService::SeasonData.new(sd, ed, params[:roster], params[:team].to_sym)
    season.seed()
    @latest = Season.last
    render :latest, formats: [:json], status: :ok
  end

  private

  def season_invalid(exception)
    render json: exception.message, status: :bad_request 
  end

end