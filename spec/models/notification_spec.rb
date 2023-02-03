# == Schema Information
#
# Table name: notifications
#
#  id                  :bigint           not null, primary key
#  order_id            :bigint
#  user_id             :bigint
#  notification_method :integer
#  event               :integer
#  sent                :boolean
#  sent_at             :datetime
#  send_errors         :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  message_body        :string
#  worker_id           :integer
#  new_order_id        :bigint
#

require 'rails_helper'

RSpec.describe Notification, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
