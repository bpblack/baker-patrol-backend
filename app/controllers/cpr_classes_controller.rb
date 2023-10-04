class CprClassesController < ApplicationController
  before_action :authenticate_user

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

  def update
    authorize CprClass
    @class = CprClass.find(params[:id])
    @class.update!(class_size: params[:size])
    head :no_content
  end
end