require 'clicksend_client'
require 'json'
class SmsNotificationWorker
  include Sidekiq::Worker

	def perform(user_id, event, new_order_id, message_body)
		@user = User.find(user_id)
		@event = event
		@new_order = NewOrder.find(new_order_id)
		@message_body = message_body

    api_instance = ClickSendClient::SMSApi.new
    sms_messages = ClickSendClient::SmsMessageCollection.new(
      messages: [
        to: "+1#{@user.phone}",
        from: "+12013316461",
        source: 'sdk',
        body: @message_body
      ]
    )

    begin
      result = api_instance.sms_send_post(sms_messages)
      json = JSON.parse(result)
      if json['response_code'] == 'SUCCESS'
        @user.notifications.create!(
          new_order_id: @new_order.id,
          notification_method: 'sms',
          event: @event,
          sent: true,
          sent_at: DateTime.current,
          message_body: @message_body
        )
      end
    rescue ClickSendClient::ApiError => e
      p e
      @user.notifications.create!(
        new_order_id: @new_order.id,
        notification_method: 'sms',
        event: event,
        sent: false,
        sent_at: DateTime.current,
        message_body: message_body,
        send_errors: e.to_s
      )
    end

  end
end
