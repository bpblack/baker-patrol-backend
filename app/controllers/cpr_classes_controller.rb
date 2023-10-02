class CprClassesController < ApplicationController
  before_action :authenticate_user

  def index
    if (params.has_key?(:students))
      @classes = CprClass.includes(:students).joins(:classroom).select('cpr_classes.*, classrooms.name as location').order(time: :asc).all
      authorize @classes[0]
      render :index_student, formats: [:json], status: :ok
    else
      @classes = CprClass.joins(:classroom).select('cpr_classes.*, classrooms.name as location').all
      authorize @classes[0]
      render formats: [:json], status: :ok
    end
  end

  def resize
    @class = CprClass.find(params[:id])
    authorize @class
    @class.update!(class_size: params[:size])
  end
end