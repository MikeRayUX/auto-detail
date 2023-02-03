class Executives::Dashboards::Support::ReopenTicketsController < ApplicationController
  before_action :authenticate_executive!

  layout 'executives/dashboard_layout'

  # executives_dashboards_support_close_tickets_path PUT
  def update
    @ticket = SupportTicket.find(params[:id])

    if @ticket.mark_opened!
      redirect_to executives_dashboards_support_support_tickets_path, flash: {
        notice: 'Ticket Reopened'
      }
    else
      redirect_to executives_dashboards_support_support_tickets_path, flash: {
        notice: @ticket.errors.full_messages.first
      }
    end
  end

end
