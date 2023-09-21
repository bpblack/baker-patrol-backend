class PatrolsController < ApplicationController
  before_action :authenticate_user
  rescue_from ActiveRecord::RecordInvalid, with: :patrol_invalid

  def index
    if params[:user_id] 
      @patrols = Patrol.duty_day_team_responsibility(params[:user_id], params[:season_id])
      render :index, formats: [:json], status: :ok 
    end
  end

  def assignable
    patrol = Patrol.includes(:user, :duty_day, :patrol_responsibility).find(params[:id])
    ignores = patrol.duty_day.ignores
    @assignable = User.subables(ignores, patrol.duty_day.season_id, patrol.patrol_responsibility.role.name)
    render formats: [:json], status: :ok
  end

  def swap
    patrol1 = Patrol.includes(:duty_day, {patrol_responsibility: :role}).find(params[:id])
    patrol2 = Patrol.includes(:duty_day, {patrol_responsibility: :role}).find(params[:with])
    if (patrol1.duty_day.id != patrol2.duty_day.id) 
      render json: "Can't swap patrol responsibilities unless the patrols are on the same duty day.", status: :bad_request
    else
      authorize patrol1
      Patrol.transaction do
        patrol1.skip_responsibility_validation = true
        patrol2.skip_responsibility_validation = true
        responsibility1 = patrol1.patrol_responsibility
        responsibility2 = patrol2.patrol_responsibility
        patrol2.update!(patrol_responsibility: nil)
        patrol1.update!(patrol_responsibility: responsibility2)
        patrol2.update!(patrol_responsibility: responsibility1)
      end
      head :no_content
    end
  end

  private

  def patrol_invalid
    render json: @substitution.errors.values.join(', '), status: :bad_request 
  end
end
