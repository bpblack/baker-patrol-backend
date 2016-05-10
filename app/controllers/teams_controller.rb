class TeamsController < ApplicationController
  before_action :authenticate

  def show
    @team = Team.includes({roster_spots: :user}, :duty_days).where(roster_spots: {season_id: params[:season_id]}, duty_days: {season_id: params[:season_id]}).find(params[:id])
    render 'teams/show.json.jbuilder', status: :ok
  end
end
