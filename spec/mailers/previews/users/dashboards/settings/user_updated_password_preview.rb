# frozen_string_literal: true

# Preview all emails at http://localhost:3001/rails/mailers/user_update_password_from_dashboard
class Users::Dashboards::Settings::UserUpdatedPasswordPreview < ActionMailer::Preview
  def send_email
    @user = User.new(
      full_name: 'John Doe',
      email: 'jdoe@gmail.com'
    )
    @timestamp = DateTime.current.strftime('%m/%d/%Y at %I:%M%P')

    Users::Dashboards::Settings::UserUpdatedPasswordMailer.send_email(
      @user,
      @timestamp
    )
  end
end
