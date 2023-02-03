# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::Dashboards::Settings::UserUpdatedPasswordMailer, type: :mailer do
  describe 'User get a password change email' do
    user = User.new(
      full_name: 'John Doe',
      email: 'jdoe@gmail.com'
    )
    timestamp = DateTime.current.strftime('%m/%d/%Y at %I:%M%P')
    mail = Users::Dashboards::Settings::UserUpdatedPasswordMailer.send_email(
      user,
      timestamp
    )

    html_email = mail.html_part.body
    text_email = mail.text_part.body

    it 'renders the recipient' do
      expect(mail.to).to eq([user.email])
    end

    it 'renders the subject' do
      expect(mail.subject).to eq('Fresh & Tumble - Your Password Was Changed')
    end

    it 'renders the sender email' do
      expect(mail.from).to eq(['no-reply@freshandtumble.com'])
    end

    it 'contains the customer name in email body' do
      expect(html_email).to match(user.full_name)
      expect(text_email).to match(user.full_name)
    end

    it 'html email contains a login link' do
      @login_link = '<a href="' + new_user_session_url + '">this link</a>'
      expect(html_email).to match(@login_link)
    end

    it 'contains a notice about possible account compromise' do
      @message = 'If you did not request this change or feel that your account may have been compromised, log in to your account'
      expect(html_email).to match(@message)
      expect(text_email).to match(@message)
    end

    it 'contains a copyright notice' do
      @notice = "© #{Date.current.year} Fresh And Tumble LLC"
      expect(html_email).to include(@notice)
      expect(text_email).to include(@notice)
    end

    it 'contains the customer name in email body' do
      expect(html_email).to match(user.full_name)
      expect(text_email).to match(user.full_name)
    end

    it 'contains a login link' do
      @login_url = new_user_session_url
      expect(text_email).to match(@login_url)
      expect(html_email).to match(@login_url)
    end

    it 'contains a notice about possible account compromise' do
      @message = 'If you did not request this change or feel that your account may have been compromised, log in to your account'
      expect(text_email).to match(@message)
      expect(html_email).to match(@message)
    end

    it 'contains a copyright notice' do
      @notice = "© #{Date.current.year} Fresh And Tumble LLC"
      expect(text_email).to include(@notice)
      expect(html_email).to include(@notice)
    end
  end
end
