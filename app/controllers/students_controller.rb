class StudentsController < ApplicationController
  before_action :authenticate_user
  rescue_from ActiveRecord::ActiveRecordError, with: :student_invalid

  def index
    authorize Student
    @students = Student.order(last_name: :asc, first_name: :asc).all
    render formats: [:json], status: :ok
  end

  def create
    authorize Student
    @student = Student.create!(first_name: params[:first_name].strip, last_name: params[:last_name].strip, email: params[:email].strip, email_sent: true, cpr_class: nil)
    StudentMailer.reminder_email(@student.name, Base64.urlsafe_encode64(@student.id.to_s), false, @student.email).deliver_later
    render formats: [:json], status: :ok
  end

  # show for signup json?

  def remind
    authorize Student
    email_counter = 0
    students = Student.where('cpr_class_id IS NULL')
    students.each do |student| 
      unless student.email.nil?
        StudentMailer.reminder_email(student.name, Base64.urlsafe_encode64(student.id.to_s), student.email_sent?, student.email).deliver_later
        email_counter += 1
        unless student.email_sent?
          student.update!(email_sent: true)
        end
      end
    end
    render json: {email_count: email_counter}, status: :ok
  end

  def update
    authorize Student
    @student = Student.find(params[:id])
    @student.update!(cpr_class_id: params[:cpr_class_id])
    head :no_content
  end

  def remove
    authorize Student
    Student.where(id: params[:remove_list], cpr_class: nil).destroy_all
    head :no_content
  end

  private

  def student_invalid(exception)
    render json: exception.message, status: :bad_request 
  end
end