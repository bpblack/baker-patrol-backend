class SeasonsController < ApplicationController
  before_action :authenticate_user

  def latest 
    authorize Season
    @latest = Season.last
    render formats: [:json], status: :ok
  end

  def create
    include BakerDataService
    authorize Season
  end
end