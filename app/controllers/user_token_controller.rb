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
      lifetime = Time.now+Rails.application.config.jwt[:lifetime]
      if lifetime
        lifetime = (user.has_role?(:staff) ? Time.now+12.hour : Time.now+lifetime.to_i).to_i
      end
      user_data = lifetime.nil? ? {sub: user.id} : {exp: lifetime, sub: user.id}
      token = encode_user_data(user_data)

      # return to user
      render json: { jwt: token }
    else
      render json: "Invalid credentials" , status: 401
    end
  end
end
