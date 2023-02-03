# frozen_string_literal: true

module Accessible
  extend ActiveSupport::Concern
  included do
    before_action :check_user
  end

    protected

  def check_user
    if current_user
      flash.clear
      # The authenticated root path can be defined in your routes.rb in: devise_scope :user do...
      # current_user.update_attribute(:active, true)
      redirect_to users_dashboards_homes_path
    elsif current_worker
      flash.clear
      # if you have rails_admin. You can redirect anywhere really
      redirect_to workers_dashboards_open_appointments_path
    elsif current_executive
      flash.clear
      # if you have rails_admin. You can redirect anywhere really
      redirect_to executives_dashboards_homes_path
   end
  end
end
