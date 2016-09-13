class SubstitutionsController < ApplicationController
  before_action :authenticate_user
  rescue_from ActiveRecord::RecordInvalid, with: :sub_invalid
  rescue_from ActiveRecord::RecordNotDestroyed, with: :sub_not_destroyed 

  def index
    if params[:user_id].present?
      u_id = params[:user_id]
      s_id = params[:season_id].present? ? params[:season_id] : Season.current_season_id
      assignable = params[:assignable].present? ? ActiveModel::Type::Boolean.new.cast(params[:assignable]) : false
      authorize Substitution.new({user_id: u_id}) #current user must match ids or be an admin
      @requests = Substitution.user_subs(u_id, s_id, is_sub: false, is_assignable: assignable)
      @substitutions = Substitution.user_subs(u_id, s_id, is_sub: true, is_assignable: assignable)
      render 'substitutions/index.user.json.jbuilder', status: :ok
    elsif params[:patrol_id].present?
      @patrol_with_subs = Patrol.duty_day_team_responsibility_subs(params[:patrol_id])
      authorize Substitution.new({patrol: @patrol_with_subs}) #current user must be admin or team leader
      render 'substitutions/index.patrol.json.jbuilder', status: :ok
    else
      render nothing: true, status: :bad_request
    end
  end

  def create
    # test that patrol owned by current user or current user is admin
    if params[:patrol_id]
      patrol = Patrol.includes(:duty_day, :user, {patrol_responsibility: :role}).find(params[:patrol_id])
      @substitution = Substitution.new(user_id: patrol.user_id, patrol: patrol, reason: params[:reason])
      authorize @substitution #current user must match patrol user id, be an admin, or be the duty day team leader
      if params[:assigned_id]
        sub = User.find(params[:assigned_id])
        if (sub.has_role?(patrol.patrol_responsibility.role.name))
          @substitution.sub_id = params[:assigned_id]
          status = :accepted
          json = {id: nil, sub_id: sub.id, sub_name: sub.name}
        else 
          status = :bad_request
          json = {error: "#{sub.name} cannot be assigned #{patrol.patrol_responsibility.name} v#{patrol.patrol_responsibility.version}"}
        end
      else
        status = :created
        json = {id: nil, sub_id: nil, sub_name: nil}
      end
      @substitution.save!
      json[:id] = @substitution.id
      if @substitution.sub_id.nil?
        ignores = patrol.duty_day.ignores
        emails = User.subables(ignores, patrol.duty_day.season_id, patrol.patrol_responsibility.role_id).pluck(:email)
        SubstitutionMailer.request_sub(@substitution, emails, params[:message]).deliver_later
      else
        SubstitutionMailer.assign_sub(@substitution).deliver_later
      end
      render json: json, status: status
    else
      render nothing: true, status: :bad_request
    end
  end

  def assign
    @substitution = Substitution.includes(:user, {patrol: [:duty_day, {patrol_responsibility: :role}]}).find(params[:id])
    authorize @substitution #user must be an admin, the requesting patroller, or the duty day team leader
    assigned_sub = User.find(params[:assigned_id])
    if (assigned_sub.has_role?(@substitution.patrol.patrol_responsibility.role.name)) 
      @substitution.update!(sub: assigned_sub)
      SubstitutionMailer.assign_sub(@substitution).deliver_later
      render json: {id: @substitution.id, sub_id: assigned_sub.id, sub_name: assigned_sub.name}, status: :accepted
    else 
      patrol_responsibility = @substitution.patrol.patrol_responsibility
      render json: {error: "#{user.name} cannot be assigned #{patrol_responsibility.name} v#{patrol_responsibility.version}"}, status: :bad_request
    end
  end

  def accept
    @substitution = Substitution.includes(:user, :sub, {patrol: :duty_day}).find(params[:id])
    authorize @substitution #user must be admin or the sub
    Substitution.transaction do
      @substitution.update!(accepted: true)
      @substitution.patrol.update!(user_id: @substitution.sub_id)
    end
    SubstitutionMailer.accept_sub_request(@substitution).deliver_later
    head :no_content
  end

  def reject
    @substitution = Substitution.includes(:user, :sub, {patrol: :duty_day}).find(params[:id])
    authorize @substitution #user must be admin or the sub
    SubstitutionMailer.reject_sub_request(@substitution, params[:message]).deliver_later
    @substitution.update!(sub: nil)
  end

  def remind
    @substitution = Substitution.includes(:user, :sub, {patrol: [:duty_day, :patrol_responsibility]}).find(params[:id])
    authorize @substitution #user must be admin, team leader, or the requesting patroller
    if @substitution.completed?
      render json: {error: "Can't send a a reminder email for a request that is complete."}, status: :bad_request
    else
      if @substitution.sub.nil?
        ignores = @substitution.patrol.duty_day.ignores
        emails = User.subables(ignores, @substitution.patrol.duty_day.season_id, @substitution.patrol.patrol_responsibility.role_id).pluck(:email)
      else
        emails = [@substitution.sub.email]
      end
      SubstitutionMailer.remind(@substitution, emails, params[:message]).deliver_later
      head :no_content
    end
  end

  def destroy
    @substitution = Substitution.includes({patrol: :duty_day}).find(params[:id])
    authorize @substitution #current user must be the owner, an admin, or duty day team leader
    @substitution.destroy!
    head :no_content
  end

  private

  def sub_invalid
    render json: {error: @substitution.errors.values.join(', ')}, status: :bad_request 
  end

  def sub_not_destroyed
    render json: {error: @substitution.errors.values.join(', ')}, status: :bad_request
  end

end
