class AskForReviewMailer < ApplicationMailer

	def send_email(user)
		@user = user

		mail(
			to: @user.email,
			from: 'announcements@freshandtumble.com',
			subject: 'How did we do?'
		)
	end
end
