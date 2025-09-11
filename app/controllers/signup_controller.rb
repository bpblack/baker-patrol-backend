class SignupController < ApplicationController
  rescue_from ActiveRecord::ActiveRecordError, with: :signup_invalid 

  def show
    latest = CprYear.last
    unless latest.expired?
      @cprs = CprStudent.includes(:student).find_by(email_token: params[:id], cpr_year_id: latest.id)
      @classes = CprClass.joins(:classroom).select('cpr_classes.*, classrooms.name as name, classrooms.address as address, classrooms.map_link as map_link').
                          order(time: :asc).where(cpr_year_id: latest.id)
      @ior = Rails.application.config.cpr_ior
      if @cprs && @classes
        render formats: [:json], status: :ok
      else
        render json: "Cannot signup at this time. Please check the url matches the one in the signup email.", status: :bad_request
      end
    else
      render json: "CPR classes are not currently running.", status: :bad_request
    end
  end

  def update
    latest = CprYear.last
    unless latest.expired?
      cprs = CprStudent.find_by!(email_token: params[:id], cpr_year_id: latest.id)
      class_id = Integer(params[:cpr_class_id])
      if class_id == 0
        class_id = nil
      end
      class_full = false
      if class_id 
        cprc = CprClass.find(class_id)
        class_full = cprc.students_count == cprc.class_size
      end
      unless class_full
        first_signup = cprs.cpr_class_id.nil?
        cprs.update!(cpr_class_id: class_id)
        if first_signup
          StudentMailer.signup_email(cprs.student.name, cprs.student.email, cprc.time_str, cprc.classroom.name, 
            cprc.classroom.address, cprc.classroom.map_link, cprc.classroom.note).deliver_later
        else
          StudentMailer.class_changed_email(cprs.student.name, cprs.student.email, cprc.time_str, cprc.classroom.name, 
            cprc.classroom.address, cprc.classroom.map_link, cprc.classroom.note).deliver_later
        end
        head :no_content
      else
        render json: "The requested class is already full.", status: :bad_request
      end
    else
      render json: "CPR classes are not currently running.", status: :bad_request
    end
  end

  private

  def signup_invalid(exception)
    if exception.is_a?(ActiveRecord::RecordNotFound) 
      render json: "Could not find a matching #{exception.model}", status: :bad_request
    else
      render json: exception.message, status: :bad_request
    end
  end
end
