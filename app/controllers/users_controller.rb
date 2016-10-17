class UsersController < ApplicationController
  before_action :authenticate_user
  rescue_from ActiveRecord::RecordInvalid, with: :user_invalid

  def update
    @user = User.find(params[:id])
    authorize @user
    if (params[:first_name])
      @user.password_validation = false
      update = {first_name: params[:first_name], last_name: params[:last_name]}
    elsif (params[:email])
      @user.password_validation = false
      update = {email: params[:email]}
    elsif (params[:phone])
      @user.password_validation = false
      update = {phone: params[:phone]}
    elsif (params[:password])
      if (!@user.authenticate(params[:password]))
        error = "Password is incorrect"
      else
        update = {password: params[:new_password], password_confirmation: params[:confirm_password]}
      end
    end
    if (!error)
      @user.update_attributes!(update)
      head :no_content
    else
      render json: {error: error}, status: :not_acceptable
    end
  end

  def extra
    @user = User.includes(:seasons, :roster_spots, :roles).find(params[:id])
    authorize @user
    json = @user.as_json(
      only: [:phone, :email],
      methods: :name,
      include: [{seasons: {only: [:id, :name, :start, :end]}}]
    )
    json[:roles] = @user.roles.map do |r|
      if r.name.to_sym == :leader  
        rs = RosterSpot.find(r.resource_id)    
        {role: :leader, team_id: rs.team_id, season_id: rs.season_id}    
      else    
        {role: r.name.to_sym}    
      end  
    end
    render json: json, status: :ok
  end

  private

  def user_invalid
    render json: {error: @user.errors.values.join(', ')}, status: :not_acceptable
  end
end
