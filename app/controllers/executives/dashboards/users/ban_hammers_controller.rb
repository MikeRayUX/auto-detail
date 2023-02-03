class Executives::Dashboards::Users::BanHammersController < ApplicationController
  before_action :authenticate_executive!

  # executives_dashboards_users_ban_hammers_path
  def update
    @user = User.find(params[:id])
    if params[:ban] == 'true' 
      @user.ban!
      redirect_to executives_dashboards_users_customer_path(@user.id)
    else
      @user.unban!
      redirect_to executives_dashboards_users_customer_path(@user.id)
    end
  end

  private
end