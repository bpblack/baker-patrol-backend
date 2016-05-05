class PatrolsController < ApplicationController
  before_action :authenticate

  def index
    if params[:user_id] 
      @patrols = Patrol.joins(:duty_day, :patrol_responsibility).select(
          'patrols.id,' \
          'patrols.duty_day_id,'\
          'duty_days.date,'\
          'duty_days.season_id,'\
          'patrols.patrol_responsibility_id,'\
          'patrol_responsibilities.name AS responsibility_name,'\
          'patrol_responsibilities.version AS responsibility_version,'\
          '(case when duty_days.date < current_date then false else true end) as swappable'
        ).where(user_id: params[:user_id])
    end
    render json: {patrols: @patrols}, status: :ok
  end
end
