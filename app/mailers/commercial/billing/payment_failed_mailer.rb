class Commercial::Billing::PaymentFailedMailer < ApplicationMailer
  def send_email(transaction)
    @t = transaction
    @client = @t.client

    mail(
      to: @client.email,
      subject: "We Were Unable To Charge You | FreshAndTumble"
    )
  end
end
