class Announcements::GeneralAnnouncementMailer < ApplicationMailer
	def send_email(user)
		@user = user

		mail(
			to: @user.email,
			subject: "[COVID-19 Update] What We Are Doing",
			from: "announcements@freshandtumble.com"
		)
	end

end
