class DutyDaysController < ApplicationController
  before_action :authenticate_user
  
  def index
    authorize DutyDay.new(season_id: params[:season_id])
    if (params[:season_id])
      @duty_days = DutyDay.includes(:team).where(season_id: params[:season_id]).order(:date)
      render json: @duty_days.as_json(include: [{team: {only: [:id, :name]}}], only: [:id, :date]), status: :ok
    else
      head :bad_request
    end
  end

  def show
    role_order = Rails.application.config.duty_day_patrol_ranks[:role]
    patrol_order = Rails.application.config.duty_day_patrol_ranks[:responsibility]
    @duty_day = DutyDay.includes(:team, {patrols: [:user, {patrol_responsibility: :role}, :latest_substitution]}).find(params[:id])
    @sorted_patrols = @duty_day.patrols.sort do |x, y| 
      ret = role_order[x.patrol_responsibility.role.name.to_sym] <=> role_order[y.patrol_responsibility.role.name.to_sym]
      if ret == 0
        xpr = x.patrol_responsibility.name.downcase.tr(" ", "_")
        ypr = y.patrol_responsibility.name.downcase.tr(" ", "_")
        ret = (patrol_order.fetch(xpr.to_sym, patrol_order[:unspecified]).to_s + xpr) <=> (patrol_order.fetch(ypr.to_sym, patrol_order[:unspecified]).to_s + ypr)
      end
      ret
    end
    @isAdmin = current_user.has_role?(:admin) || 
      current_user.has_role?(:leader, current_user.roster_spots.find_by(season_id: @duty_day.season_id, team_id: @duty_day.team_id)) || 
      current_user.has_role?(:staff, current_user.roster_spots.find_by(season_id: @duty_day.season_id)) 
    render 'duty_days/show.json.jbuilder', status: :ok
  end  

  def available_patrollers
    @duty_day = DutyDay.find(params[:id])
    authorize @duty_day
    available = User.subables(@duty_day.ignores, @duty_day.season_id, :onhill).pluck(:email)
    render json: {emails: available}, status: :ok
  end 
end
