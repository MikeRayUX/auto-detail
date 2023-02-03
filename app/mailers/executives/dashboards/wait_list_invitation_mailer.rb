class Executives::Dashboards::WaitListInvitationMailer < ApplicationMailer
  def send_email(wait_list)
    @wait_list = wait_list

    mail(
      to: @wait_list.email,
      subject: "WooHoo! We Are Now In Your Area!",
      from: "announcement@freshandtumble.com"
    )
  end
  
end
