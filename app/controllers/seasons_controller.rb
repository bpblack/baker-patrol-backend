class SeasonsController < ApplicationController
  require 'csv'
  include BakerDataService
  before_action :authenticate_user
  rescue_from ActiveRecord::ActiveRecordError, with: :season_invalid
  rescue_from IOError, with: :season_invalid
  rescue_from SystemCallError, with: :season_invalid
  rescue_from JSON::JSONError, with: :season_invalid
  rescue_from CSV::MalformedCSVError, with: :season_invalid
  rescue_from CSV::Parser::InvalidEncoding, with: :season_invalid
  rescue_from CSV::Parser::UnexpectedError, with: :season_invalid
  rescue_from BakerDataService::SeasonDataError, with: :season_invalid 

  def latest 
    authorize Season
    @latest = Season.last
    render formats: [:json], status: :ok
  end

  def create
    authorize Season
    sd = DateTime.parse(params[:start]).to_date
    ed = DateTime.parse(params[:end]).to_date
    season_service = BakerDataService::SeasonData.new()
    season_service.seed(sd, ed, params[:roster], params[:team].to_sym)
    @latest = Season.last
    render :latest, formats: [:json], status: :ok
  end

  private

  def season_invalid(exception)
    render json: exception.message, status: :bad_request 
  end

end