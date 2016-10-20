class DutyDaysController < ApplicationController
  before_action :authenticate_user
  
  def index
    authorize DutyDay
    if (params[:season_id])
      @duty_days = DutyDay.includes(:team).where(season_id: params[:season_id])
      render json: @duty_days.as_json(include: [{team: {only: [:id, :name]}}], only: [:id, :date]), status: :ok
    else
      head :bad_request
    end
  end

  def show
    role_order = {onhill: 1, aidroom: 2, host: 3}
    patrol_order = {team_leader: "a", base: "z"} # this is a string that is < all other patrol name strings
    @duty_day = DutyDay.includes(:team, {patrols: [:user, {patrol_responsibility: :role}, :latest_substitution]}).find(params[:id])
    @sorted_patrols = @duty_day.patrols.sort do |x, y| 
      ret = role_order[x.patrol_responsibility.role.name.to_sym] <=> role_order[y.patrol_responsibility.role.name.to_sym]
      if ret == 0
        xpr = x.patrol_responsibility.name.downcase.tr(" ", "_")
        ypr = y.patrol_responsibility.name.downcase.tr(" ", "_")
        ret = patrol_order.fetch(xpr.to_sym, xpr) <=> patrol_order.fetch(ypr.to_sym, ypr)
      end
      ret
    end
    @isAdmin = current_user.has_role?(:admin) || current_user.has_role?(:leader, current_user.roster_spots.find_by(season_id: @duty_day.season_id, team_id: @duty_day.team_id))
    render 'duty_days/show.json.jbuilder', status: :ok
  end  
end
