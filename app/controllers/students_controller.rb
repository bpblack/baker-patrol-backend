class StudentsController < ApplicationController
  before_action :authenticate_user
  rescue_from ActiveRecord::ActiveRecordError, with: :student_invalid

  def index
    authorize Student
    @students = CprStudent.includes(:student).all.sort_by { |s| [s.student.last_name, s.student.first_name]}
    render formats: [:json], status: :ok
  end

  def create
    authorize Student
    last = CprYear.last
    if (last && !last.expired())
      external = CprExternalStudent.find_by(email: params[:email].strip)
      unless external
        external = CprExternalStudent.find_by(last_name: params[:last_name].strip, first_name: params[:first_name].strip)
      end
      unless external
        external = CprExternalStudent.create!(first_name: params[:first_name].strip, last_name: params[:last_name].strip, email: params[:email].strip)
      end
      @student = CprStudent.new()
      @student.cpr_year = CprYear.last
      @student.student = external
      @student.generate_token
      @student.email_sent = false;
      @student.has_cpr_cert = false
      @student.save!
      if CprClass.exists?(cpr_year_id: last.id)
        StudentMailer.reminder_email(external.name, @student.email_token, false, external.email).deliver_later
        @student.email_sent = true;
        @student.save!
      end
      render formats: [:json], status: :ok
    else
      render json: {message: "Cannot register external cpr student."}, status: :bad_request
    end
  end

  # show for signup json?

  def remind
    authorize Student
    last = CprYear.last
    if (last && !last.expired())
      email_counter = 0
      cprstudents = CprStudent.where('cpr_class_id IS NULL')
      cprstudents.each do |cprs| 
        unless cprs.student.email.nil? || cprs.has_cpr_cert
          StudentMailer.reminder_email(cprs.student.name, student.email_token, student.email_sent?, cprs.student.email).deliver_later
          email_counter += 1
          unless student.email_sent?
            student.update!(email_sent: true)
          end
        end
      end
      render json: {email_count: email_counter}, status: :ok
    else
      render json: {message: "Cannot remind cpr students."}, status: :bad_request
    end 
  end

  def update
    authorize Student
    last = CprYear.last
    if (last && !last.expired())
      @student = CprStudent.find(params[:id])
      ActiveRecord::Base.transaction do
        if (params[:cpr_class_id] == 0) 
          if (@student.cpr_class_id) 
            CprClass.decrement_counter(:students_count, @student.cpr_class_id)
          end
          @student.update!(cpr_class_id: nil, has_cpr_cert: true);
        else 
          if (params[:cpr_class_id] == nil)
            CprClass.decrement_counter(:students_count, @student.cpr_class_id)
          else
            CprClass.increment_counter(:students_count, params[:cpr_class_id])
          end
          @student.update!(cpr_class_id: params[:cpr_class_id], has_cpr_cert: false)
        end
      end
      head :no_content
    else
      render json: {message: "Cannot update cpr student."}, status: :bad_request
    end
  end

  def remove
    authorize Student
    last = CprYear.last
    if (last && !last.expired())
      CprStudent.where(id: params[:remove_list], has_cpr_cert: false, cpr_class: nil).destroy_all
      head :no_content
    else
      render json: {message: "Cannot remove cpr student."}, status: :bad_request
    end 
  end

  private

  def student_invalid(exception)
    render json: exception.message, status: :bad_request 
  end
end