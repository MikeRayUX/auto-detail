# == Schema Information
#
# Table name: holidays
#
#  id         :bigint           not null, primary key
#  title      :string
#  date       :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'rails_helper'

RSpec.describe Holiday, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
