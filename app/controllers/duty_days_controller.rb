class DutyDaysController < ApplicationController
  before_action :authenticate_user
  
  def show
    @duty_day = DutyDay.includes(:team, {patrols: [:user, :patrol_responsibility, :latest_substitution]}).find(params[:id])
    @isAdmin = current_user.has_role?(:admin) || current_user.has_role?(:leader, current_user.roster_spots.find_by(season_id: @duty_day.season_id, team_id: @duty_day.team_id))
    render 'duty_days/show.json.jbuilder', status: :ok
  end  
end
