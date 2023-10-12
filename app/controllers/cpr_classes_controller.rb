class CprClassesController < ApplicationController
  before_action :authenticate_user
  rescue_from ActiveRecord::ActiveRecordError, with: :class_invalid 

  def index
    authorize CprClass
    if (params.has_key?(:students))
      @classes = CprClass.includes(:students).joins(:classroom).select('cpr_classes.*, classrooms.name as location').order(time: :asc).all
      render :index_student, formats: [:json], status: :ok
    else
      @classes = CprClass.joins(:classroom).select('cpr_classes.*, classrooms.name as location').order(time: :asc).all
      render formats: [:json], status: :ok
    end
  end

  def create
    authorize CprClass
    time = DateTime.strptime(DateTime.parse(params[:time]).in_time_zone.to_s[0..-9]+'00', '%Y-%m-%d %H:%M:%S') # Dirty strip off time zone since everything is pst
    @class = CprClass.create!(time: time, class_size: params[:class_size], students_count: 0, classroom_id: params[:classroom_id])
    render formats: [:json], status: :ok
  end

  def update
    authorize CprClass
    @class = CprClass.find(params[:id])
    @class.update!(class_size: params[:size])
    head :no_content
  end

  private

  def class_invalid(exception)
    render json: exception.message + exception.backtrace.join("&nbsp;"), status: :bad_request 
  end
end