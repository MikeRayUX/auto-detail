# frozen_string_literal: true

class Api::V1::Washers::AuthsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :set_default_format
  before_action :authenticate_washer!

  private
  def set_default_format
    request.format = :json
  end

  def authenticate_washer!
    payload = JsonWebToken.decode(auth_token)
    @current_washer = Washer.find_by(email: payload.first['sub'])
  rescue JWT::ExpiredSignature
    render json: {
      code: 3000,
      message: 'auth_error',
      errors: ['Your session has expired. Please log in to continue.'],
      status: :unauthorized
    }
  rescue JWT::DecodeError
    render json: {
      code: 3000,
      message: 'auth_error',
      errors: ['Your session has expired. Please log in to continue.'],
      status: :unauthorized
    }
  rescue JWT::InvalidJtiError
    render json: {
      code: 3000,
      message: 'auth_error',
      errors: ['Your session has expired. Please log in to continue.'],
      status: :unauthorized
    }
  end

  def auth_token
    @auth_token ||= request.headers.fetch('Authorization', '').split(' ').last
  end
end
