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

require 'rails_helper'

RSpec.describe SupportTicketReply, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
