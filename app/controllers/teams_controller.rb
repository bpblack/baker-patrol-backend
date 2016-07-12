class TeamsController < ApplicationController
  before_action :authenticate_user

  def index 
    if (params[:user_id])
      rs = RosterSpot.where(user_id: params[:user_id], season_id: params[:season_id]).first
      @team = Team.includes(:duty_days, {roster_spots: :user}).where(roster_spots: {season_id: params[:season_id]}, duty_days: {season_id: params[:season_id]}).find(rs.team_id)
      render 'teams/show.json.jbuilder', status: :ok
    end
  end

  def show
    @team = Team.includes({roster_spots: :user}, :duty_days).where(roster_spots: {season_id: params[:season_id]}, duty_days: {season_id: params[:season_id]}).find(params[:id])
    render 'teams/show.json.jbuilder', status: :ok
  end
end
