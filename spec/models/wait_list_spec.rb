# == Schema Information
#
# Table name: wait_lists
#
#  id             :bigint           not null, primary key
#  zipcode        :string
#  email          :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  invite_sent_at :datetime
#

require 'rails_helper'

RSpec.describe WaitList, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
