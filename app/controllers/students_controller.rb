class StudentsController < ApplicationController
  before_action :authenticate_user
  rescue_from ActiveRecord::ActiveRecordError, with: :student_invalid

  def index
    authorize Student
    @students = CprStudent.includes(:student).where(cpr_year_id: CprYear.last).sort_by { |s| [s.student.last_name, s.student.first_name]}
    render formats: [:json], status: :ok
  end

  def create
    authorize Student
    last = CprYear.last
    if (last && !last.expired?())
      external = User.where('email ILIKE ?', params[:email].strip)[0]
      unless external
        external = CprExternalStudent.where('email ILIKE ?', params[:email].strip)[0]
      end
      unless external
        external = User.find_by(last_name: params[:last_name].strip, first_name: params[:first_name].strip)
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
      if CprClass.exists?(cpr_year_id: last.id) && CprStudent.exists?(email_sent: true)
        StudentMailer.reminder_email(external.name, @student.email_token, false, external.email).deliver_later
        @student.email_sent = true;
        @student.save!
      end
      render formats: [:json], status: :ok
    else
      render json: "Cannot register external cpr student.", status: :bad_request
    end
  end

  # show for signup json?

  def remind
    authorize Student
    latest = CprYear.last
    if (latest && !latest.expired?() && CprClass.exists?(cpr_year_id: latest.id))
      email_counter = 0
      cprstudents = CprStudent.includes(:student).where(cpr_class_id: nil, has_cpr_cert: false)
      cprstudents.each do |cprs| 
        unless cprs.student.email.nil?
          StudentMailer.reminder_email(cprs.student.name, cprs.email_token, cprs.email_sent?, cprs.student.email).deliver_later
          email_counter += 1
          unless cprs.email_sent?
            cprs.update!(email_sent: true)
          end
        end
      end
      render json: {email_count: email_counter}, status: :ok
    else
      render json: "Cannot remind cpr students unless there is a current CPR year that has classes.", status: :bad_request
    end 
  end

  def update
    authorize Student
    last = CprYear.last
    if (last && !last.expired?())
      @student = CprStudent.find(params[:id])
      if (params[:cpr_class_id].nil?)
        @student.update!(cpr_class_id: nil, has_cpr_cert: false)
      elsif (params[:cpr_class_id] == 0) 
        @student.update!(cpr_class_id: nil, has_cpr_cert: true)
      else
        klass = CprClass.find(params[:cpr_class_id])
        if (klass.students_count == klass.class_size)
          render json: "The requested class is already full.", status: :bad_request
        else
          @student.update!(cpr_class_id: params[:cpr_class_id], has_cpr_cert: false)
          head :no_content
        end
      end
    else
      render json: "Cannot update cpr student.", status: :bad_request
    end
  end

  def remove
    authorize Student
    last = CprYear.last
    if (last && !last.expired?())
      CprStudent.where(id: params[:remove_list], has_cpr_cert: false, cpr_class: nil).destroy_all
      head :no_content
    else
      render json: "Cannot remove cpr student.", status: :bad_request
    end 
  end

  private

  def student_invalid(exception)
    render json: exception.message, status: :bad_request 
  end
end