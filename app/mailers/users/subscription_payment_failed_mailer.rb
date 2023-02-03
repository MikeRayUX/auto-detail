class Users::SubscriptionPaymentFailedMailer < ApplicationMailer

  def send_email(user)
    @user = user
    @region  = @user.region
    @subscription = Subscription.first

    @tax = @subscription.tax(@region.tax_rate)
    @grandtotal = @subscription.grandtotal(@region.tax_rate)

    mail(
      to: user.email,
      from: 'no-reply@freshandtumble.com',
      subject: 'We Were Unable To Charge You | Please Update Your Payment Method'
    )
  end
end
