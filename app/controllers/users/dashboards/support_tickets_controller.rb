class Users::Dashboards::SupportTicketsController < ApplicationController
  before_action :authenticate_user!
  before_action :validate_form!, only: %i[create]

  layout 'users/dashboards/user_dashboard_layout'

  # new_users_dashboards_support_tickets_path GET
  def new
    @business_phone = '(206)414-9538'
    @orders = current_user.orders.where("created_at >= ?", 1.week.ago).where.not(global_status: ['cancelled'])
    @options_for_select = [
      ['Question/Inquiry', 'general_inquiry'],
      ['Bug Report', 'bug_report']
    ]

    if @orders.any?
      @orders.each do |o|
        @options_for_select.push([
          o.support_selectable, o.reference_code
        ])
      end
    end
  end

  # users_dashboards_support_tickets_path GET
  def show
  end

  # users_dashboards_support_tickets_path POST
  def create
    @ticket = current_user.support_tickets.build(
      customer_name: current_user.full_name,
      customer_email: current_user.email,
      customer_phone: current_user.phone,
      body: ticket_params[:body]
    )

    if ticket_params[:option] != 'general_inquiry' && ticket_params[:option] != 'bug_report'
      @order = current_user.orders.find_by(reference_code: ticket_params[:option])
      @ticket.assign_attributes(
        concern: 'order_related',
        order_id: @order.id,
        subject: "New Support Ticket | Order: #{@order.reference_code}",
        order_reference_code: @order.reference_code,
        pick_up_appointment: @order.formatted_appointment
      )
    else
      @ticket.assign_attributes(
        concern: ticket_params[:option],
        subject: 'New Support Ticket | General Inquiry'
      )
    end

    if @ticket.save
      redirect_to users_dashboards_support_tickets_path
    else
      redirect_to new_users_dashboards_support_tickets_path, flash: {
        errors: @ticket.errors.full_messages.join(', ')
      }
    end
  end

  private

  def ticket_params
    params.require(:ticket).permit(:option, :body)
  end

  def validate_form!
    unless ticket_params[:option].present? && ticket_params[:body].present?
      redirect_to new_users_dashboards_support_tickets_path, flash: {
        errors: 'You must fill out the entire form to continue.'
      }
    end
  end

end
