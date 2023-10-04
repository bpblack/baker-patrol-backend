class SubstitutionsController < ApplicationController
  before_action :authenticate_user
  rescue_from ActiveRecord::RecordInvalid, with: :sub_invalid
  rescue_from ActiveRecord::RecordNotSaved, with: :sub_invalid
  rescue_from ActiveRecord::RecordNotFound, with: :sub_not_found
  rescue_from ActiveRecord::RecordNotDestroyed, with: :sub_not_destroyed 

  def index
    if params[:user_id].present?
      # all subs for a user
      u_id = params[:user_id]
      s_id = params[:season_id].present? ? params[:season_id] : Season.current_season_id
      # parse out what to do from the given params
      if (!params[:requests].present? && !params[:substitutions].present?)
        load_requests, load_substitutions = true, true
        requests_accepted, substitutions_accepted = nil, nil
      else
        if (params[:requests].present?)
          load_requests = true
          requests_accepted = params[:requests].to_sym == :both ? nil : ActiveModel::Type::Boolean.new.cast(params[:requests])
          requests_since = params[:requests_since].present? ? params[:requests_since] : params[:since]
        end
        if (params[:substitutions].present?)
          load_substitutions = true
          substitutions_accepted = params[:substitutions].to_sym == :both ? nil : ActiveModel::Type::Boolean.new.cast(params[:substitutions])
          substitutions_since = params[:substitutions_since].present? ? params[:substitutions_since] : params[:since]
        end
      end
      load_future = params[:future].present? ? ActiveModel::Type::Boolean.new.cast(params[:future]) : nil
      authorize Substitution.new({user_id: u_id}) #current user must match ids or be an admin
      @requests = load_requests ? Substitution.user_subs(u_id, s_id, is_sub: false, accepted: requests_accepted, future: load_future, since: requests_since) : []
      @substitutions = load_substitutions ? Substitution.user_subs(u_id, s_id, is_sub: true, accepted: substitutions_accepted, future: load_future, since: substitutions_since) : []
      render :index_user, formats: [:json], status: :ok
    elsif params[:patrol_id].present?
      # all subs for a patrol
      @patrol_with_subs = Patrol.duty_day_team_responsibility_subs(params[:patrol_id])
      authorize Substitution.new({patrol: @patrol_with_subs}) #current user must be admin or team leader
      render :index_patrol, formats: [:json], status: :ok
    elsif params[:duty_day_id].present?
      # all subs for a duty day
      authorize Substitution.new({patrol: Patrol.find_by(duty_day_id: params[:duty_day_id])}) #current user must be admin or team leader
      @substitutions = Substitution.duty_day_latest_subs(params[:duty_day_id], since: params[:since])
      render :index_duty_day, formats: [:json], status: :ok
    elsif params[:season_id].present? 
      #all subs that are not assigned and are not on the current user's duty days
      dds = Patrol.duty_day(current_user.id, params[:season_id]).pluck(:duty_day_id)
      @cansub = current_user.reserve? ? [] : Substitution.joins({patrol: [{patrol_responsibility: :role}, {duty_day: :team}]}).
        select('substitutions.user_id, duty_days.id as duty_day_id, duty_days.date as date, duty_days.season_id as season_id, duty_days.season_id as season_id, patrol_responsibilities.name as responsibility, roles.name as role, teams.name as team').
        includes(:user).where(sub_id: nil, duty_days: {season: 4}).where.not(patrols: {duty_day: dds}).
        where('duty_days.date >= :today', {today: Time.zone.today})
      if (@cansub.length > 0)
        # filter based on the current user's season role
        srs = current_user.season_roster_spot(@cansub[0].season_id)
        check_roles = {onhill: current_user.has_role?(:onhill, srs), host: current_user.has_role?(:host, srs)}
        @cansub = @cansub.filter {|s| check_roles[s.role.to_sym]}
      end
      render :index_season, formats: [:json], status: :ok
    else
      render nothing: true, status: :bad_request
    end
  end

  def create
    # test that patrol owned by current user or current user is admin
    if params[:patrol_id]
      full_sanitizer = Rails::Html::FullSanitizer.new
      patrol = Patrol.includes(:duty_day, :user, {patrol_responsibility: :role}).find(params[:patrol_id])
      @substitution = Substitution.new(user_id: patrol.user_id, patrol: patrol, reason: full_sanitizer.sanitize(params[:reason]))
      if params[:assigned_id]
        sub = params[:assigned_id].to_i == 0 ? nil : User.find(params[:assigned_id])
        if sub.nil?
          @substitution.only_authorize_admin = true
          status = :created
          json = {id: nil, sub_id: nil, sub_name: nil}
        elsif (sub.has_role?(patrol.patrol_responsibility.role.name, sub.season_roster_spot(patrol.duty_day.season_id)))
          send_emails = true
          @substitution.sub_id = params[:assigned_id]
          status = :created
          json = {id: nil, sub_id: sub.id, sub_name: sub.name}
        else 
          status = :bad_request
          json = "#{sub.name} cannot be assigned #{patrol.patrol_responsibility.versioned_name}"
        end
      else
        send_emails = true
        status = :created
        json = {id: nil, sub_id: nil, sub_name: nil}
      end
      authorize @substitution #current user must match patrol user id, be an admin, or be the duty day team leader
      @substitution.save!
      json[:id] = @substitution.id
      if send_emails
        if @substitution.sub_id.nil?
          ignores = patrol.duty_day.ignores
          emails = User.subables(ignores, patrol.duty_day.season_id, patrol.patrol_responsibility.role.name).pluck(:email)
          SubstitutionMailer.request_sub(@substitution, emails, full_sanitizer.sanitize(params[:message])).deliver_later
        else
          SubstitutionMailer.assign_sub(@substitution).deliver_later
        end
      end
      render json: json, status: status
    else
      render nothing: true, status: :bad_request
    end
  end

  def assign
    @substitution = Substitution.includes(:user, {patrol: [:duty_day, {patrol_responsibility: :role}]}).find(params[:id])
    assigned_sub = params[:assigned_id].to_i == 0 ? nil : User.find(params[:assigned_id])
    @substitution.only_authorize_admin = true if assigned_sub.nil?
    authorize @substitution #user must be an admin, the requesting patroller, or the duty day team leader
    if (assigned_sub.nil? || !assigned_sub.reserve || assigned_sub.has_role?(@substitution.patrol.patrol_responsibility.role.name, assigned_sub.season_roster_spot(@substitution.patrol.duty_day.season_id))) 
      @substitution.update!(sub: assigned_sub)
      SubstitutionMailer.assign_sub(@substitution).deliver_later unless assigned_sub.nil?
      render json: {id: @substitution.id, sub_id: assigned_sub.nil? ? nil : assigned_sub.id, sub_name: assigned_sub.nil? ? nil : assigned_sub.name}, status: :accepted
    else 
      patrol_responsibility = @substitution.patrol.patrol_responsibility
      render json: "#{user.name} cannot be assigned #{patrol_responsibility.versioned_name}", status: :bad_request
    end
  end

  def accept
    @substitution = Substitution.includes(:user, :sub, {patrol: :duty_day}).find(params[:id])
    authorize @substitution #user must be the sub
    unless @substitution.accepted #don't send multiple emails on double click, second call accepted will be true
      Substitution.transaction do
        @substitution.update!(accepted: true)
        @substitution.patrol.update!(user_id: @substitution.sub_id)
      end
      SubstitutionMailer.accept_sub_request(@substitution).deliver_later
      SubstitutionGoogleCalendarJob.perform_later(@substitution)
    end
    head :no_content
  end

  def reject
    @substitution = Substitution.includes(:user, :sub, {patrol: :duty_day}).find(params[:id])
    authorize @substitution #user must be the sub 
    if @substitution.sub #don't send multiple emails if there's a double click, second call sub will be nil
      sub_name, sub_email = @substitution.sub.name, @substitution.sub.email
      @substitution.update!(sub: nil)
      full_sanitizer = Rails::Html::FullSanitizer.new
      SubstitutionMailer.reject_sub_request(@substitution, sub_name, sub_email, full_sanitizer.sanitize(params[:message])).deliver_later
    end
  end

  def remind
    @substitution = Substitution.includes(:user, :sub, {patrol: [:duty_day, :patrol_responsibility]}).find(params[:id])
    authorize @substitution #user must be admin, team leader, or the requesting patroller
    if @substitution.completed?
      render json: "Can't send a a reminder email for a request that is complete.", status: :bad_request
    elsif @substitution.sub.nil? && params[:to_id].present?
      render json: 'The sub was rejected, so the email to the previously assigned sub was not sent.', status: :bad_request
    else
      if @substitution.sub.nil?
        ignores = @substitution.patrol.duty_day.ignores
        emails = User.subables(ignores, @substitution.patrol.duty_day.season_id, @substitution.patrol.patrol_responsibility.role.name).pluck(:email)
      else
        emails = [@substitution.sub.email]
      end
      full_sanitizer = Rails::Html::FullSanitizer.new
      SubstitutionMailer.remind(@substitution, emails, full_sanitizer.sanitize(params[:message])).deliver_later
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
    render json: @substitution.errors.full_messages.join(', '), status: :bad_request 
  end

  def sub_not_destroyed
    render json: @substitution.errors.full_messages.join(', '), status: :bad_request
  end

  def sub_not_found(exception)
    model = exception.model
    model = exception.message.match(/Couldn't find ([\w]+) with 'id'=([\d]+)/)[1] if model.nil?
    case(model)
    when 'User'
      json = 'User not found.'
    when 'Patrol'
      json = 'Patrol not found.'
    when 'Substitution'
      json = 'Substituion request not found. The person requesting the sub may have deleted it.'
    end
    render json: json, status: :bad_request
  end
end
