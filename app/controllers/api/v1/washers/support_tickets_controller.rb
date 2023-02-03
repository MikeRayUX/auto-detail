class Api::V1::Washers::SupportTicketsController < Api::V1::Washers::AuthsController

  # api_v1_washers_support_tickets_path
  # /api/v1/washers/support_tickets
  def create
    @ticket = @current_washer.support_tickets.new(
      support_ticket_params.merge(
        customer_email: @current_washer.email,
        concern: 'washer_support'
      )
    )

    if @ticket.save
      render json: {
        code: 201,
        message: 'support_ticket_sent',
        details: "Your message has been sent succesffully. You will receive a response at your email: #{@current_washer.email}"
      }
    else
      render json: {
        code: 3000,
        message: 'invalid_support_ticket',
        errors: @ticket.errors.full_messages.first
      }
    end
  end
  
  private
  def support_ticket_params
    params.require(:support_ticket).permit(%i[body])
  end
end