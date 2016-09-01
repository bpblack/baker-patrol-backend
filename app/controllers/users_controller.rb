class UsersController < ApplicationController
  before_action :authenticate_user

  def extra
    @user = User.includes(:seasons, :roster_spots, :roles).find(params[:id])
    authorize @user
    json = @user.as_json(
      only: [:name],
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

end
