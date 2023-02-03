class Notifications::SmsWorker
  include Sidekiq::Worker
  sidekiq_options retry: 1

  def perform(event, user_type, id, body)
    @event, @user_type, @id, @body = event, user_type, id, body

    @model = get_model(@user_type, @id)
    
    api_instance = ClickSendClient::SMSApi.new
    sms_messages = ClickSendClient::SmsMessageCollection.new(
      messages: [
        to: "+1#{@model.phone}",
        from: "+12013316461",
        source: 'sdk',
        body: @body
      ]
    )

    @sms = @model.notifications.new(
      notification_method: 'sms',
      event: @event,
      sent: true,
      sent_at: DateTime.current,
      message_body: @body
    )

    result = api_instance.sms_send_post(sms_messages)

    @sms.save!
  rescue ClickSendClient::ApiError => e
    @sms.assign_attributes(
      sent: false,
      send_errors: e
    )

    @sms.save!
  end
end

def get_model(user_type, id)
  case user_type
  when 'user'
    User.find(id)
  when 'worker'
    Worker.find(id)
  when 'washer'
    Washer.find(id)
  end
end

