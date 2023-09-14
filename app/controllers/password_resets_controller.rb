class PasswordResetsController < ApplicationController
  rescue_from ActiveRecord::RecordInvalid, with: :reset_invalid

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
    update = {password: params[:password], password_confirmation: params[:confirm_password], password_reset_token: nil}
    @user = User.find_by_password_reset_token(params[:id])
    update[:activated] = true unless @user.nil? || @user.activated?
    if @user
      if @user.password_reset_sent_at < 2.hours.ago && @user.activated?
        render json: {error: 'Reset link has expired'}, status: :forbidden
      else
        @user.update_attributes!(update)
        head :no_content
      end
    else
      render json: {error: 'Invalid reset token'}, status: :not_found
    end
  end

  private
  def reset_invalid
    render json: {error: @user.errors.values.join(', ')}, status: :not_acceptable
  end
end
