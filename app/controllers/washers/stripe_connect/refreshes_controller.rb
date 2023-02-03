class Washers::StripeConnect::RefreshesController < ApplicationController
  layout 'static_pages/no_nav_layout'

  # washers_stripe_connect_refreshes_path(id) GET
 def show
    @washer = Washer.find_by(stripe_account_id: params[:id])

    if @washer && @washer.requires_stripe_setup?
      @new_setup_link = @washer.new_stripe_setup_link
    end
  end
end