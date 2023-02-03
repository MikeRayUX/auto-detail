# frozen_string_literal: true

class Executives::Dashboards::WaitListsController < ApplicationController
  before_action :authenticate_executive!

  layout 'executives/dashboard_layout'

  # executives_dashboards_wait_lists_path
  def index
    @list_items = WaitList.all.order(created_at: :desc)
  end

  # send invite email
  # executives_dashboards_wait_list_path
  def update
    @waiter = WaitList.find(params[:id])

    if @waiter
      @waiter.send_invitation_email!
      @waiter.update(invite_sent_at: DateTime.current)

      redirect_to executives_dashboards_wait_lists_path, flash: {
        notice: "Invitation Email Sent Successfully."
      }
    else
      redirect_to executives_dashboards_wait_list_path(id: @waiter.id), flash: {
        notice: "List item doesn't exist"
      }
    end
  end

  # executives_dashboards_wait_list_path
  def destroy
    @waiter = WaitList.find(params[:id])

    if @waiter && @waiter.destroy
      redirect_to executives_dashboards_wait_lists_path, flash: {
        notice: 'Wait list item deleted successfully.'
      }
    else
      redirect_to executives_dashboards_wait_lists_path, flash: {
        notice: 'Wait list item does not exist.'
      }
    end
  end

  private
  def wait_list_params
    params.require(:wait_list).permit(%i[
      invited_at
    ])
  end
end