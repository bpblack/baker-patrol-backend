class SeasonsController < ApplicationController
  include BakerDataService
  before_action :authenticate_user

  def latest 
    authorize Season
    @latest = Season.last
    render formats: [:json], status: :ok
  end

  def create
    authorize Season
  end
end