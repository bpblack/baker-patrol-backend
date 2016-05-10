class PatrolsController < ApplicationController
  before_action :authenticate

  def index
    if params[:user_id] 
      @patrols = Patrol.includes({duty_day: :team}, :patrol_responsibility).where(user_id: params[:user_id], duty_days: {season_id: params[:season_id]})
      render 'patrols/index.user.json.jbuilder', status: :ok 
    end
    #render json: {patrols: @patrols}, status: :ok
  end
end
