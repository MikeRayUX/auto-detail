class Api::V1::Users::Dashboards::SupportTicketsController < ApiController

  # /api/v1/users/dashboards/support_tickets
  # api_v1_users_dashboards_support_tickets_path 
  def create
    @ticket = @current_user.support_tickets.build(
      concern: 'customer_app',
      subject: 'New Support Ticket | General Inquiry',
      customer_name: @current_user.full_name,
      customer_email: @current_user.email,
      customer_phone: @current_user.phone,
      body: ticket_params[:body]
    )

    if @ticket.save
      render json: {
        code: 201,
        message: 'ticket_created',
        feedback: "Your message has been received. Please allow up to 48 hours to receive a response. You will receive a reply at your email: #{@current_user.email}. If you don't hear back soon, please check your spam folder"
      }
    else
      render json: {
        code: 3000,
        message: 'ticket_invalid',
        errors: @ticket.errors.full_messages.join(', ')
      }
    end
  end

  private

  def ticket_params
    params.require(:ticket).permit(:body)
  end
end
