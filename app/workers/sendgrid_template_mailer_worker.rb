require 'sendgrid-ruby'
include SendGrid

# ACCESS TEMPLATES AT https://mc.sendgrid.com/dynamic-templates
# OFFICIAL EXAMPLE FROM SENDGRID DOCS
# https://github.com/sendgrid/sendgrid-ruby/blob/main/use-cases/transactional-templates.md 

class SendgridTemplateMailerWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(recipient_id, recipient_type, sendgrid_email_id)
    @sendgrid_email = SendgridEmail.find(sendgrid_email_id)

    if (recipient_type == 'users')
      @recipient = User.find(recipient_id)
    else
      @recipient = Washer.find(recipient_id)
    end

    mail = SendGrid::Mail.new
    mail.from = Email.new(email: 'announcements@freshandtumble.com')

    personalization = Personalization.new
    personalization.add_to(Email.new(email: @recipient.email))

    # NOTE:
    # variables in sendgrid dynamic templates are accessed in the template by using handlebars syntax {{user}} (or any variable you want in the template builder on sendgrid.com 
    personalization.add_dynamic_template_data({
      user: @recipient.first_name.present? ? @recipient.first_name.capitalize : ""
    })

    mail.add_personalization(personalization)
    mail.template_id = @sendgrid_email.template_id

    sg = SendGrid::API.new(api_key: SENDGRID_API_KEY)

    begin
      @email_send = @recipient.email_sends.new(
        sendgrid_email_id: @sendgrid_email.id,
      ) 

      response = sg.client.mail._("send").post(request_body: mail.to_json)

      status_code = response.status_code.to_i

      if status_code == 202
        @email_send.status = 'sent'
      else
        json = JSON.parse(response.body).with_indifferent_access
        @email_send.status = 'failed'
        @email_send.api_errors = json[:errors].first[:message]
      end

      @email_send.save
    end

  end
end