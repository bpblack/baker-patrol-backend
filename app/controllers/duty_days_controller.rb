class DutyDaysController < ApplicationController
  before_action :authenticate_user
  
  def show
    @duty_day = DutyDay.includes(:team, {patrols: :user}, {patrols: :patrol_responsibility}).find(params[:id])
    render 'duty_days/show.json.jbuilder', status: :ok
  end  
end
