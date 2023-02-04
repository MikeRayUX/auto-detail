# Preview all emails at http://localhost:3000/rails/mailers/ask_for_review
class AskForReviewPreview < ActionMailer::Preview
	def send_email

		@user = User.new(
			full_name: Faker::Name.name,
			email: Faker::Internet.email,
			
		)

		AskForReviewMailer.send_email(@user)
	end

end
