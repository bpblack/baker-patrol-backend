class PasswordResetsController < ApplicationController
  rescue_from ActiveRecord::RecordInvalid, with: :reset_invalid

  def create
    user = User.find_by_email(params[:email])
    if user
      user.send_password_reset
      head :no_content
    else
      render 'Invalid email address', status: :not_found
    end
  end

  def update
    @user = User.find_by_password_reset_token(params[:id])
    if @user
      if @user.password_reset_sent_at < 2.hours.ago && @user.activated?
        render 'Reset link has expired', status: :forbidden
      else
        @user.update!(password: params[:password], password_confirmation: params[:confirm_password], password_reset_token: nil, activated: true)
        head :no_content
      end
    else
      render json: 'Invalid reset token', status: :not_found
    end
  end

  private
  def reset_invalid
    render json: @user.errors.full_messages.join(', '), status: :not_acceptable
  end
end
