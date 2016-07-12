class PatrolsController < ApplicationController
  before_action :authenticate_user

  def index
    if params[:user_id] 
      @patrols = Patrol.duty_day_team_responsibility(params[:user_id], params[:season_id])
      render 'patrols/index.user.json.jbuilder', status: :ok 
    end
    #render json: {patrols: @patrols}, status: :ok
  end
end
