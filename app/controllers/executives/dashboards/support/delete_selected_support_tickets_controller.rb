# frozen_string_literal: true
class Executives::Dashboards::Support::DeleteSelectedSupportTicketsController < ApplicationController
  before_action :authenticate_executive!

  # executives_dashboards_support_delete_selected_support_tickets_path
  def destroy
    # blank means none were selected and button text works double as delete all
    if params[:ticket_ids].blank?
      SupportTicket.destroy_all
      redirect_to executives_dashboards_support_support_tickets_path, flash: {
        notice: "All Support Tickets Deleted"
      }
    else
      params[:ticket_ids].each do |id|
        @ticket = SupportTicket.find(id.to_i)
        @ticket.destroy
      end

      redirect_to executives_dashboards_support_support_tickets_path, flash: {
        notice: "#{params[:ticket_ids].length} Support Tickets Deleted."
      }
    end
  end

  private
  def model_params
    params.require(:support_tickets).permit(%i[
      ticket_ids
    ])
  end
end