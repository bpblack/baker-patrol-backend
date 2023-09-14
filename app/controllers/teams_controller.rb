class TeamsController < ApplicationController
  before_action :authenticate_user

  def index 
    if params[:season_id].present?
      if params[:user_id].present?
        rs = RosterSpot.find_by(user_id: params[:user_id], season_id: params[:season_id])
        render_team_with_duty_days(id: rs.team_id, season_id: params[:season_id])
      else
        authorize Team.new(roster_season_id: params[:season_id])
        @teams = Team.season_roster_spots(season_id: params[:season_id], preload: true).all
        render formats: [:json], status: :ok
      end
    else
      head :bad_request
    end
  end

  def show
    render_team_with_duty_days(id: params[:id], season_id: params[:season_id])
  end

  private
  def render_team_with_duty_days(id:, season_id:)
    @team = Team.season_roster_spots(season_id: season_id, preload: true).find(id)
    @duty_days = @team.duty_days.where(season_id: season_id)
    @leader = @team.leader(season_id)
    render :show, formats: [:json], status: :ok
  end
end
