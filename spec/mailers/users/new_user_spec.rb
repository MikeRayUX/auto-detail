# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Users::NewUserMailer, type: :mailer do
  describe 'New user gets a signup email' do
    before do
      @user = User.new(attributes_for(:user))

      @mail = Users::NewUserMailer.send_email(@user).deliver_now

      @html_body = @mail.html_part.body
      @text_body = @mail.text_part.body
    end

    it 'renders the subject' do
      expect(@mail.to).to eq([@user.email])
    end

    it 'renders the sender email' do
      expect(@mail.from).to eq(['no-reply@freshandtumble.com'])
    end

    it 'contains the customer name in html body' do
      expect(@html_body).to match(@user.full_name)
    end

    it 'contains a copyright notice in html body' do
      @notice = "© #{Date.current.year} Fresh And Tumble LLC"
      expect(@html_body).to include(@notice)
    end

    it 'contains the customer name in text body' do
      expect(@text_body).to match(@user.full_name)
    end

    it 'contains a copyright notice in text body' do
      @notice = "© #{Date.current.year} Fresh And Tumble LLC"
      expect(@text_body).to include(@notice)
    end
  end
end
