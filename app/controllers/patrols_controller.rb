class PatrolsController < ApplicationController
  before_action :authenticate_user

  def index
    if params[:user_id] 
      @patrols = Patrol.duty_day_team_responsibility(params[:user_id], params[:season_id])
      render 'patrols/index.user.json.jbuilder', status: :ok 
    end
    #render json: {patrols: @patrols}, status: :ok
  end

  def assignable
    patrol = Patrol.includes(:user, :duty_day, :patrol_responsibility).find(params[:id])
    ignores = patrol.duty_day.patrols.pluck(:user_id)
    @assignable = User.subables(ignores, patrol.duty_day.season_id, patrol.patrol_responsibility.role_id)
    render 'patrols/assignable.json.jbuilder', status: :ok
  end
end
