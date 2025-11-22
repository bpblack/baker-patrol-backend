class UserTokenController < ApplicationController
  def create
    # use postgres ILIKE query for email lookup
    user = User.where('email ILIKE ?', params[:auth][:email])[0]

    # you can use bcrypt to password authentication
    if user && user.authenticate(params[:auth][:password])
      unless user.activated
        user.activated = true
        user.save(validate: false)
      end
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
