class Executives::Dashboards::Support::SupportTicketRepliesController < ApplicationController
  before_action :authenticate_executive!

  layout 'executives/dashboard_layout'

  # executives_dashboards_support_reply_to_ticket_path PUT
  def create
    @ticket = SupportTicket.find(params[:id])
    @user = @ticket.user
    @reply = @ticket.replies.new(reply_params)

    if @reply.save
      @reply.send_reply_email!(@ticket, @user)
      redirect_to executives_dashboards_support_support_ticket_path(@ticket.id), flash: {
        notice: 'Reply Sent.'
      }
    else
      redirect_to executives_dashboards_support_support_ticket_path(@ticket.id), flash: {
        notice: @reply.errors.full_messages.first
      }
    end
  end

  # executives_dashboards_support_reply_to_ticket_path DELETE
  def destroy
    @t = SupportTicket.find(params[:id])
    if @t.destroy
      redirect_to executives_dashboards_support_open_tickets_path, flash: {
        notice: 'Ticket deleted'
      }
    else
      redirect_to executives_dashboards_support_support_ticket_path(@t.id), flash: {
        notice: 'Could not delete tickewt'
      }
    end
  end

  private

  def reply_params
    params.require(:support_ticket_reply).permit(%i[
      body
    ])
  end

end