class ClassroomsController < ApplicationController
  before_action :authenticate_user
  rescue_from ActiveRecord::ActiveRecordError, with: :classroom_invalid

  def index
    authorize Classroom
    @classrooms = Classroom.all
    render formats: [:json], status: :ok
  end

  def create
    authorize Classroom
    @classroom = Classroom.create!(name: params[:name].strip, address: params[:address].strip, map_link: params[:map_link].strip)
    render formats: [:json], status: :ok
  end

  private

  def classroom_invalid(exception)
    render json: exception.message, status: :bad_request 
  end
end