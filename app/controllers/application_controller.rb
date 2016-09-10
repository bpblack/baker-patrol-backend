class ApplicationController < ActionController::API
  include Knock::Authenticable
  include Pundit
  
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  
  def index
    render file: 'public/index'
  end

  private 
  def not_found(exception)
    render json: {error: exception.to_s}, status: :not_found
  end

  def user_not_authorized
    render json: {error: 'Not authorized to perform action.'}, status: :unauthorized
  end

end
