class Executives::Dashboards::Users::CustomersController < ApplicationController
  before_action :authenticate_executive!
  layout 'executives/dashboard_layout'

  # executives_dashboards_users_customers_path GET
  def index
    @all_users = User.all.includes(:new_orders).newest
    if params[:sorted].present?
      case params[:sorted]
      when 'all'
        @users = @all_users.page(params[:page]).per(User.all.count)
      when 'newest'
        @users = @all_users.page(params[:page]).per(75)
      when 'oldest'
        @users = @all_users.oldest.page(params[:page]).per(75)
      when 'cancelled'
        @users = @all_users.cancelled.page(params[:page]).per(75)
      else
        @users = @all_users.page(params[:page]).per(75)
      end
    else
      @users = @all_users.page(params[:page]).per(75)
    end
  end

  # executives_dashboards_users_customer_path
  def show
    @user = User.find(params[:id])
    @orders = @user.new_orders.order(created_at: :desc)
    @support_tickets = @user.support_tickets.order(created_at: :desc)
  end

  # edit_executives_dashboards_users_customer_path EDIT
  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params) 
      flash[:success] = "Object was successfully updated"
      redirect_to executives_dashboards_users_customer_path(@user.id)
    else
      flash[:error] = "Something went wrong"
      render 'edit'
    end
  end

  def destroy; end

  def user_params
    params.require(:user).permit(%i[
      email
      phone
      full_name
      sms_enabled
      promotional_emails
      business_review_left
    ])
  end

  def address_params
    params.requier(:address).permit(%i[
      unit_number
      city
      state
      zipcode
      street_address
      pick_up_directions
      phone
    ])
  end
end
