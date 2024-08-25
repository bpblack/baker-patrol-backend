class CprClassesController < ApplicationController
  before_action :authenticate_user
  rescue_from ActiveRecord::ActiveRecordError, with: :class_invalid 

  def index
    authorize CprClass
    year_id = nil
    latest = CprYear.last
    year_id = latest ? latest.id : nil
    if (params.has_key?(:students))
      @classes = CprClass.includes(:students).joins(:classroom).select('cpr_classes.*, classrooms.id as cr_id, classrooms.name as cr_name').order(time: :asc).where(cpr_year_id: year_id)
      render :index_student, formats: [:json], status: :ok
    else
      @classes = CprClass.joins(:classroom).select('cpr_classes.*, classrooms.id as cr_id, classrooms.name as cr_name').order(time: :asc).where(cpr_year_id: year_id)
      render formats: [:json], status: :ok
    end
  end

  def create
    authorize CprClass
    latest = CprYear.last
    if !latest || latest.expired
      render json: {message: "Please create a current CPR year before creating classes."}, status: :bad_request
    else
      @class = CprClass.create!(time: get_time(params[:time]), class_size: params[:class_size], students_count: 0, classroom_id: params[:classroom_id], cpr_year_id: latest.id)
      render formats: [:json], status: :ok
    end
  end

  def update
    authorize CprClass
    latest = CprYear.last
    if !latest || latest.expired
      render json: {message: "Please create a current CPR year before updating classes."}, status: :bad_request
    else
      @class = CprClass.find(params[:id])
      @class.update!(classroom_id: params[:classroom_id], time: get_time(params[:time]), class_size: params[:class_size])
      render :create, formats: [:json], status: :ok
    end
  end

  private

  def class_invalid(exception)
    render json: exception.message, status: :bad_request 
  end

  def get_time(time_str)
    DateTime.strptime(DateTime.parse(time_str).in_time_zone.to_s[0..-9]+'00', '%Y-%m-%d %H:%M:%S') # Dirty strip off time zone since everything is pst
  end
end