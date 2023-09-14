class ApplicationController < ActionController::API
  include Pundit::Authorization
  include ActionController::HttpAuthentication::Token::ControllerMethods
  
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def current_user
    @current_user
  end

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

  protected

  attr_reader :current_user

  def authenticate_user
    user = authenticate_with_http_token do |token, options| 
      # getting user id from a nested JSON in an array.
      decode_data = decode_user_data(token) 
      # find a user in the database to be sure token is for a real user
      @current_user = User.find(decode_data[0]["sub"]) unless !decode_data
    end
    
    # The barebone of this is to return true or false, as a middleware
    # its main purpose is to grant access or return an error to the user
    if @current_user
      return true
    else
      render json: { message: "invalid credentials" }
    end
  end

  # turn user data (payload) to an encrypted string  [ B ]
  def encode_user_data(payload)
    JWT.encode payload, Rails.application.secret_key_base, Rails.application.config.jwt[:signature_algorithm]
  end

  # decode token and return user info, this returns an array, [payload and algorithms] [ A ]
  def decode_user_data(token)
    begin
      data = JWT.decode(token, Rails.application.secret_key_base, true, { algorithm: Rails.application.config.jwt[:signature_algorithm] })
      return data
    rescue => e
      puts e
    end
  end

end
