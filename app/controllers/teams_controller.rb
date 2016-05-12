class TeamsController < ApplicationController
  before_action :authenticate

  def index 
    if (params[:user_id])
      @team = Team.includes(:duty_days).joins(:roster_spots).where(roster_spots: {season_id: params[:season_id], user_id: params[:user_id]}, duty_days: {season_id: params[:season_id]}).take
      @team.roster_spots.includes(:user)
      render 'teams/show.json.jbuilder', status: :ok
    end
  end

  def show
    @team = Team.includes({roster_spots: :user}, :duty_days).where(roster_spots: {season_id: params[:season_id]}, duty_days: {season_id: params[:season_id]}).find(params[:id])
    render 'teams/show.json.jbuilder', status: :ok
  end
end
