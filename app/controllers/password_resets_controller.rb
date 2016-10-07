class PasswordResetsController < ApplicationController
  def create
    user = User.find_by_email(params[:email])
    if user
      user.send_password_reset
      head :no_content
    else
      render json: {error: 'Invalid email address'}, status: :not_found
    end
  end

  def update
    if params[:password] != params[:confirm_password]
      render json: {error: "Reset passwords don't match."}, status: :not_acceptable and return
    end
    update = {password: params[:password], password_reset_token: nil}
    @user = User.find_by_password_reset_token(params[:id])
    update[:activated] = true unless @user.activated?
    if @user
      if @user.password_reset_sent_at < 2.hours.ago && @user.activated?
        render json: {error: 'Reset link has expired'}, status: :forbidden
      else
        begin
          @user.update_attributes!(update)
          head :no_content
        rescue ActiveRecord::RecordInvalid => invalid
          render json: {error: 'Password invalid'}, status: :not_acceptable
        end
      end
    else
      render json: {error: 'Invalid reset token'}, status: :not_found
    end
  end
end
