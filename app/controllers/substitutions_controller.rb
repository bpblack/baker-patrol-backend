class SubstitutionsController < ApplicationController
  before_action :authenticate_user
  rescue_from ActiveRecord::RecordNotFound, with: :sub_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :sub_invalid
  rescue_from ActiveRecord::RecordNotDestroyed, with: :sub_not_destroyed 
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

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
      patrol = Patrol.includes(:duty_day, :user, :patrol_responsibility).find(params[:patrol_id])
      substitution = Substitution.new(user_id: patrol.user_id, patrol: patrol, reason: params[:reason])
      authorize substitution #current user must match patrol user id or be an admin
      substitution.save!
      ignores = patrol.duty_day.patrols.pluck(:user_id)
      emails = User.sub_email_list(ignores, patrol.duty_day.season_id)
      SubstitutionMailer.request_sub(substitution, emails, params[:message]).deliver_now 
      head :no_content
    else
      render nothing: true, status: :bad_request
    end
  end

  def update
    substitution = Substitution.includes(:user, :sub, {patrol: :duty_day}).find(params[:id])
    authorize substitution #current user must either be the owner, the sub, or an admin
    if params[:assigned_sub_id]
      assign_sub(substitution,  User.find(params[:assigned_sub_id]))
    elsif params[:accept]
      accept_sub(substitution, ActiveModel::Type::Boolean.new.cast(params[:accept]))
    end
  end

  def destroy
    sub = Substitution.includes({patrol: :duty_day}).find(params[:id])
    authorize sub #current user must be the owner or an admin
    sub.destroy!
    head :no_content
  end

  private
  def assign_sub(substitution, assigned_sub)
    sub_request.update!(sub: assigned_sub)
    SubstitutionMailer.assign_sub(substitution).deliver_now
    head :no_content
  end

  def accept_sub(substitution, accept)
    if accept
      substitution.update(accepted: true)
      substitution.patrol.update(user_id: sub.sub_id)
      SubstitutionMailer.accept_sub_request(substitution).deliver_now
    else
      SubstitutionMailer.reject_sub_request(substitution).deliver_now
      substitution.update(sub: nil)
    end
    head :no_content
  end

  def sub_not_found(exception)
    render json: {error: "No #{exception.model} found for #{exception.id}"}, status: :not_found
  end

  def sub_invalid(exception)
    render json: {error: exception.errors}, status: :bad_request 
  end

  def sub_not_destroyed(exception)
    render json: {error: exception.errors}, status: :bad_request
  end

  def not_authorized
    render json: {error: 'Not authorized to perform action.'}, status: :not_authorized
  end

end
