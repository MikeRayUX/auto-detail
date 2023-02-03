# Preview all emails at http://localhost:3001/rails/mailers/support/inquiry
class Support::InquiryPreview < ActionMailer::Preview

  def send_email
    @inquiry = Inquiry.create!(
      email: Faker::Internet.email,
      body: Faker::GreekPhilosophers.quote
    )

    @mailer = Support::InquiryMailer.send_email(
      @inquiry.id
    )
  end

end
