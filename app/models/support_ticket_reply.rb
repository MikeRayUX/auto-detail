# == Schema Information
#
# Table name: support_ticket_replies
#
#  id                :bigint           not null, primary key
#  support_ticket_id :bigint
#  body              :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class SupportTicketReply < ApplicationRecord
  validates :body, presence: true

  belongs_to :support_ticket

  def send_reply_email!(ticket, user)
    Support::SupportTickets::ReplyMailer.send_email(ticket, user, self).deliver_later
  end

  def created_with_time
    created_at.strftime('%m/%d/%Y at %I:%M%P')
  end
end
