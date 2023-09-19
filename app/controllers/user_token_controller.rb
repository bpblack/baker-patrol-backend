class UserTokenController < ApplicationController
  def create
    user = User.find_by(email: params[:auth][:email])

    # you can use bcrypt to password authentication
    if user && user.authenticate(params[:auth][:password])
      # we encrypt user info using the pre-define methods in application controller
      user_data = Rails.application.config.jwt[:lifetime].nil? ? {sub: user.id} : {exp: (Time.now+Rails.application.config.jwt[:lifetime]).to_i, sub: user.id}
      token = encode_user_data(user_data)

      # return to user
      render json: { jwt: token }
    else
      render json: "Invalid credentials" , status: 401
    end
  end
end
