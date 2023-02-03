class Executives::Dashboards::Support::SupportTicketsController < ApplicationController
  before_action :authenticate_executive!

  layout 'executives/dashboard_layout'

  # executives_dashboards_support_support_tickets_path GET
  def index
    @tickets = SupportTicket.order('created_at DESC')
  end

  # executives_dashboards_support_support_ticket_path GET
  def show
    @t = SupportTicket.find(params[:id])
    @replies = @t.support_ticket_replies
    @t.mark_viewed
  end

  # executives_dashboards_support_support_ticket_path PUT
  def update

  end

  # executives_dashboards_support_support_ticket_path DELETE
  def destroy
    @t = SupportTicket.find(params[:id])
    if @t.destroy
      redirect_to executives_dashboards_support_support_tickets_path, flash: {
        notice: 'Ticket deleted'
      }
    else
      redirect_to executives_dashboards_support_support_ticket_path(@t.id), flash: {
        notice: @t.errors.full_messages.first
      }
    end
  end

  def support_ticket_params
    params.require(:support_ticket).permit(%i[id])
  end
end