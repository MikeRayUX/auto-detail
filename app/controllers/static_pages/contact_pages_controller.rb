class StaticPages::ContactPagesController < ApplicationController
  before_action :verify_recaptcha, only: %i[create]

  layout 'static_pages/static_pages_layout'

  def new
    @contact_phone = '(206)414-9538'
    @contact_email = 'info@freshandtumble.com'
  end

  def show

  end

  def create
    @ticket = SupportTicket.new(
      ticket_params.merge(concern: 'general_inquiry')
    )

    if @ticket.save 
      redirect_to static_pages_contact_pages_path
    else
      redirect_to contactus_path, flash: {
        error: @ticket.errors.full_messages[0]
      }
    end
  end

  private 
  def verify_recaptcha
    if params['g-recaptcha-response'].present?
      response = HTTParty.put(
        'https://www.google.com/recaptcha/api/siteverify', 
        query: {
          secret: RECAPTCHA_V2_SECRET_KEY,
          response: params['g-recaptcha-response']
        }
      )

       if response && response.parsed_response['success'] == true
        true
       else
        redirect_to contactus_path, flash: {
          error: 'You must complete the captcha to submit a message'
        }
       end
    else
      redirect_to contactus_path, flash: {
        error: 'You must complete the captcha to submit a message'
      }
    end
  end

  def ticket_params
    params.require(:support_ticket).permit(%i[customer_email body])
  end
end
