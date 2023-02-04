# Preview all emails at http://localhost:3000/rails/mailers/announcements/general_announcement
class Announcements::GeneralAnnouncementPreview < ActionMailer::Preview

	def send_email
		@user = User.new(
			full_name: 'Mike Arriaga',
      email: 'arriaga562@gmail.com',
      password: 'password',
      password_confirmation: 'password',
      phone: '5627872684',
		)

		Announcements::GeneralAnnouncementMailer.send_email(@user)
	end

end
