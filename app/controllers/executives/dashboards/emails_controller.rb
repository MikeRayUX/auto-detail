class Executives::Dashboards::EmailsController < ApplicationController
  before_action :authenticate_executive!
  layout 'executives/dashboard_layout'

  # new_executives_dashboards_email_path
  def new
    @email = SendgridEmail.new
  end

  # executives_dashboards_emails_path
  def create
    @email = SendgridEmail.new(sendgrid_email_params.merge(category: sendgrid_email_params[:category].to_i))

    if @email.save
      redirect_to executives_dashboards_emails_path, flash: {
        notice: 'Template created.'
      }
    else
      redirect_to new_executives_dashboards_email_path, flash: {
        notice: @email.errors.full_messages.first
      }
    end
  end

  # executives_dashboards_emails_path
  def index
    @emails = SendgridEmail.all.order(created_at: :desc)
  end

  # executives_dashboards_email_path
  def destroy
    @email = SendgridEmail.find(params[:id])

    if @email.destroy
      redirect_to executives_dashboards_emails_path, flash: {
        notice: 'Email Deleted Successfully'
      }
    else
      redirect_to executives_dashboards_emails_path, flash: {
        notice: 'Email Not Deleted'
      }
    end
  end

  private
  def sendgrid_email_params
    params.require(:sendgrid_email).permit(%i[
      template_id
      description
      content_summary
      preview_url
      category
    ])
  end
end