class SignupController < ApplicationController
  rescue_from ActiveRecord::ActiveRecordError, with: :signup_invalid 

  def show
    latest = CprYear.last
    unless latest.expired?
      @cprs = CprStudent.includes(:student).find_by(email_token: params[:id], cpr_year_id: latest.id)
      @classes = CprClass.joins(:classroom).select('cpr_classes.*, classrooms.id as cr_id, classrooms.name as cr_name').order(time: :asc).where(cpr_year_id: latest.id)
      if @cprs && @classes
        render formats: [:json], status: :ok
      else
        render json: {message: "Cannot signup at this time. Please check the url matches the one in the signup email."}, status: :bad_request
      end
    else
      render json: {message: "CPR classes are not currently running."}, status: :bad_request
    end
  end

  def update
    latest = CprYear.last
    unless latest.expired?
      cprs = CprStudent.find_by(email_token: params[:id], cpr_year_id: latest.id)
      cpr_class = CprClass.find(params[:cpr_class_id])
      if cprs == nil
        render json: {message: "Cannot signup at this time. Please check the url matches the one in the signup email."}, status: :bad_request
      elsif cpr_class == nil
        render json: {message: "Received an invalid cpr class id."}, status: :bad_request
      else
        cprs.update!(cpr_class_id: cpr_class.id)
        head :no_content
      end
    else
      render json: {message: "CPR classes are not currently running."}, status: :bad_request
    end
  end

  private

  def signup_invalid(exception)
    render json: exception.message, status: :bad_request 
  end
end
