# frozen_string_literal: true

class Api::V1::Washers::WorkSessionsController < Api::V1::Washers::AuthsController
  before_action :check_activation_status, only: %i[create update]
  before_action :validate_session, only: %i[update destroy]

  # /api/v1/washers/work_sessions POST
  # api_v1_washers_work_sessions_path
  def create
    if @current_washer.work_sessions.refreshable.any?
      @current_washer.kill_active_sessions!
    end

    @session = @current_washer.go_online

    render json: {
      code: 201,
      status: :ok,
      message: 'session_created',
      session_id: @session.secure_id
    }
  end

  # /api/v1/washers/work_sessions/1 PUT
  # api_v1_washers_work_session_path  
  # REFRESHES SESSION
  def update
    if @session.refreshable?
      @session.refresh!
      @current_washer.refresh_online_status
      render json: {
        code: 204,
        status: :ok,
        message: 'session_refreshed',
        session_id: @session.secure_id
      }
    else
      @session.terminate!
      @current_washer.go_offline
      render json: {
        code: 3000,
        message: 'session_terminated',
        errors: 'Session Expired.',
        session_id: @session.secure_id
      }
    end
  end

  # /api/v1/washers/work_sessions/1 DELETE
  # api_v1_washers_work_session_path  
  def destroy
    # p params
    # @session = @current_washer.work_sessions.find_by(secure_id: params[:secure_id])

    if @session && @session.terminatable?
      @session.terminate!
      @current_washer.go_offline
      render json: {
        code: 204,
        status: :ok,
        message: 'session_terminated',
        session_id: @session.secure_id
      }
    else
      render json: {
        code: 204,
        status: :ok,
        message: 'session_already_terminated'
      }
    end
  end

  private
  def work_session_params
    params.require(:work_session).permit(%i[secure_id])
  end

  def check_activation_status
    unless @current_washer.activated?
      @current_washer.go_offline
      render json: {
        code: 3000,
        message: 'not_activated',
        errors: 'Your account is not currently activated. Please contact support@freshandtumble.com to resume offers.'
      }
    end
  end

  def validate_session
    @session = @current_washer.work_sessions.find_by(secure_id: work_session_params[:secure_id])

    unless @session.present?
      @current_washer.go_offline
      render json: {
        code: 3000,
        message: 'session_expired',
        errors: 'Your session has expired. Please enable Go Online again.'
      }
    end
  end
end
