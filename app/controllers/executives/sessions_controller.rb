# frozen_string_literal: true

class Executives::SessionsController < Devise::SessionsController
  layout 'static_pages/no_nav_layout'
  # before_action :configure_sign_in_params, only: [:create]
  include Accessible
  skip_before_action :check_user, except: %i[new create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  def after_sign_in_path_for(resource)
    super(resource)
    executives_dashboards_homes_path
  end

  def after_sign_out_path_for(resource)
    super(resource)
    new_executive_session_path
  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end
