class TeamsController < ApplicationController
  before_action :authenticate_user

  def index 
    if params[:user_id].present?
      rs = RosterSpot.find_by(user_id: params[:user_id], season_id: params[:season_id])
      @team = Team.season_roster_spots_duty_days(params[:season_id]).find(rs.team_id)
      render 'teams/show.json.jbuilder', status: :ok
    end
  end

  def show
    @team = Team.season_roster_spots_duty_days(params[:season_id]).find(params[:id])
    render 'teams/show.json.jbuilder', status: :ok
  end
end
