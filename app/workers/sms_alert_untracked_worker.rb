require 'clicksend_client'

class SmsAlertUntrackedWorker
  include Sidekiq::Worker

  def perform(phone, message)
    @phone, @message = phone, message

    api_instance = ClickSendClient::SMSApi.new
    sms_messages = ClickSendClient::SmsMessageCollection.new(
      messages: [
        to: "+1#{@phone}",
        from: "+12013316461",
        source: 'sdk',
        body: @message
      ]
    )
    begin
      api_instance.sms_send_post(sms_messages)
    rescue ClickSendClient::ApiError => e
      p e
      true
    end
  end
end