class Users::Dashboards::BillingsController < ApplicationController
	before_action :authenticate_user!
	
  layout 'users/dashboards/user_dashboard_layout'

	def index
		@user = current_user

		if @user.transactions.any?
			@transactions = @user.transactions
		end
	end
end
