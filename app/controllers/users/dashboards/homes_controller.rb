# frozen_string_literal: true

class Users::Dashboards::HomesController < ApplicationController
  before_action :authenticate_user!

  layout 'users/dashboards/user_dashboard_layout'

  def index
    @orders = current_user.new_orders.in_progress

    if @orders.any?
      @order = @orders.last
    end
  end
end
