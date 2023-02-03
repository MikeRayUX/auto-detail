# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
  layout 'static_pages/no_nav_layout'
  # GET /resource/password/new
  # def new
  #   super
  # end

  # POST /resource/password
  # def create
  #   super
  # end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/password
  # def update
  #   super
  # end

  # protected

  def after_resetting_password_path_for(resource)
    # super(resource)
    new_user_session_path
  end

  # The path used after sending reset password instructions
  def after_sending_reset_password_instructions_path_for(resource_name)
    flash[:notice] = "We have sent an email with the instructions to reset your password"
    super(resource_name)
    new_user_password_path
    
    # redirect_to new_user_password_path
  end
end
