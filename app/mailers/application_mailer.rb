# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: 'no-reply@freshandtumble.com'
  layout 'mailer'
end
