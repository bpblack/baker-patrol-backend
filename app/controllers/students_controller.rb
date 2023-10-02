class StudentsController < ApplicationController
  before_action :authenticate_user

  def index
    @students = Student.order(last_name: :asc, first_name: :asc).all
    render formats: [:json], status: :ok
  end
end