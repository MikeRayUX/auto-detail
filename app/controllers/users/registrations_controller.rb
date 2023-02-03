# frozen_string_literal: true

class Users::RegistrationsController < ApplicationController
  layout 'static_pages/no_nav_layout'
  def new; end

  def create
    @user = User.new(user_params.merge(
      password_confirmation: user_params[:password]
    ))
    if @user.valid?
      @user.save!
      @user.send_welcome_email!
      sign_in @user

      redirect_to users_dashboards_homes_path
    else
      redirect_to signup_path, flash: {
        error: @user.errors.full_messages[0]
      }
    end
  end

  private

  def user_params
    params.require(:user).permit(:full_name, :phone, :email, :password)
  end
end
