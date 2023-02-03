class Users::MailingLists::MarketingEmailsController < ApplicationController

	def show
		if @user = User.read_unsub_token(params[:token])
			@user.unsubscribe_from_promotional_emails! unless @user.unsubscribed?
			render plain: "You've been unsubscribed from the mailing list."
		else
			render plain: 'Invalid Link'
		end
	end
end
