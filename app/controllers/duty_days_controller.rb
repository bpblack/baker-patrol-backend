class DutyDaysController < ApplicationController
  before_action :authenticate
  
  def show
    @duty_day = DutyDay.joins(:team).select('duty_days.id, duty_days.date, teams.name').find(params[:id])
    render json: {duty_day: @duty_day, patrollers: @duty_day.users}, status: :ok
  end  
end
