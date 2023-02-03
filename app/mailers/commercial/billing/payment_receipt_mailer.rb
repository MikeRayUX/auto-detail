class Commercial::Billing::PaymentReceiptMailer < ApplicationMailer
  def send_email(transaction)
    @t = transaction
    @client = @t.client

    mail(
      to: @client.email,
      subject: "Your Laundry Service Receipt | Thank You!"
    )
  end
end
