# Preview all emails at http://localhost:3000/rails/mailers/users/subscription_create
class Users::SubscriptionCreatePreview < ActionMailer::Preview
  def send_email
    @user = User.new(
      email: 'arriaga562@gmail.com',
      full_name: 'John Doe',
      subscription_activated_at: DateTime.current
    )

    Users::SubscriptionCreateMailer.send_email(@user)
  end
end
