# == Schema Information
#
# Table name: work_sessions
#
#  id                 :bigint           not null, primary key
#  washer_id          :bigint
#  last_checked_in_at :datetime
#  terminated_at      :datetime
#  secure_id          :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'rails_helper'

RSpec.describe WorkSession, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
