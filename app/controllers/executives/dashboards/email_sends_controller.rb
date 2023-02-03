# frozen_string_literal: true

class Executives::Dashboards::EmailSendsController < ApplicationController
  before_action :authenticate_executive!
  before_action :determine_recipients, only: %i[create]
  layout 'executives/dashboard_layout'

  # new_executives_dashboards_email_send_path
  def new
    @email = SendgridEmail.find(params[:sendgrid_email_id])
  end

  # executives_dashboards_email_sends_path
  def create
    @email = SendgridEmail.find(email_send_params[:sendgrid_email_id])

    if @recipients.any?
      @recipients.each do |recipient|
        SendgridTemplateMailerWorker.perform_async(
          recipient.id,
          email_send_params[:recipient_type],
          @email.id
        )
      end
      redirect_to executives_dashboards_email_sends_path(sendgrid_email_id: @email.id), flash: {
        notice: "Email Sent Successfully to all #{email_send_params[:recipient_type].upcase} within the #{@region.area.upcase} region."
      }
    else
      redirect_to new_executives_dashboards_email_send_path(sendgrid_email_id: @email.id), flash: {
        notice: 'Email not sent. No receipients'
      }
    end
  end

  # executives_dashboards_email_sends_path
  def index
    @email = SendgridEmail.find(params[:sendgrid_email_id])
    @sends = @email.email_sends.all.order(created_at: :desc)
  end

  private
  def email_send_params
    params.require(:email_send).permit(%i[
      recipient_type
      region_id
      sendgrid_email_id
    ])
  end

  def determine_recipients
    @region = Region.find(email_send_params[:region_id])
    @recipients = []

    case email_send_params[:recipient_type]
    when 'users'
      @addresses = Address.where.not(user_id: nil).where(region_id: @region.id)

      if @addresses.any?
        @addresses.each do |a|
          @recipients.push(a.user)
        end
      end
    when 'washers'
      @recipients = @region.washers.activated
    end
  end
end