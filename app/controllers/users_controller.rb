class UsersController < ApplicationController
  before_action :authenticate_user
  rescue_from ActiveRecord::RecordInvalid, with: :user_invalid

  def update
    @user = User.find(params[:id])
    authorize @user
    if (params[:first_name])
      @user.password_validation = false
      update = {first_name: params[:first_name].strip, last_name: params[:last_name].strip}
    elsif (params[:email])
      @user.password_validation = false
      update = {email: params[:email].strip}
    elsif (params[:phone])
      @user.password_validation = false
      update = {phone: params[:phone].strip}
    elsif (params[:password])
      if (!@user.authenticate(params[:password]))
        error = "Password is incorrect"
      elsif (params[:new_password] != params[:confirm_password])
        error = "New password does not match confirmation"
      else
        update = {password: params[:new_password], password_confirmation: params[:confirm_password]}
      end
    end
    if (!error)
      @user.update!(**update)
      head :no_content
    else
      render json: error, status: :not_acceptable
    end
  end

  def extra
    @user = User.includes(:seasons, :roster_spots, :roles).find(params[:id])
    authorize @user
    json = @user.as_json(
      only: [:first_name, :last_name, :phone, :email],
      #methods: :name,
      include: [{seasons: {only: [:id, :name, :start, :end]}}]
    )
    latest_rs_id = @user.roster_spots[-1].id
    json[:roles] = @user.roles.select {|r| r.resource_id.nil? || r.resource_id == latest_rs_id}.map do |r|
      if r.name.to_sym == :leader  
        rs = RosterSpot.find(r.resource_id)    
        {role: :leader, team_id: rs.team_id, season_id: rs.season_id}    
      elsif r.name.to_sym == :staff
        rs = RosterSpot.find(r.resource_id)
        {role: :staff, team_id: nil, season_id: rs.season_id}
      else    
        {role: r.name.to_sym}    
      end  
    end
    json[:cpr_token] = nil
    cpry = CprYear.last
    unless cpry.nil? || cpry.expired?
      cprs = CprStudent.find_by(student_type: 'User', student_id: @user.id, cpr_year_id: cpry.id)
      if cprs
        json[:cpr_token] = cprs.email_token
      end
    end
    render json: json, status: :ok
  end

  def email_new
    authorize User
    begin
      new_users = User.where(activated: false).where.not(password_reset_token: nil)
      new_users.each do |nu|
        nu.update_attribute(:password_reset_sent_at, Time.zone.now)
        UserMailer.new_user(nu).deliver_later 
      end
      render json: {email_count: new_users.length}, status: :ok
    rescue Exception => e
      render json: e.message, status: :not_acceptable
    end
  end

  private

  def user_invalid
    render json: @user.errors.full_messages.join(', '), status: :not_acceptable
  end
end
