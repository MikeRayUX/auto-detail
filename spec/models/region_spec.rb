# == Schema Information
#
# Table name: regions
#
#  id                      :bigint           not null, primary key
#  area                    :string
#  tax_rate                :float
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  washer_capacity         :integer          default(0)
#  price_per_bag           :decimal(12, 2)
#  washer_pay_percentage   :float
#  stripe_tax_rate_id      :string
#  last_washer_offer_check :datetime
#  max_concurrent_offers   :integer
#  failed_pickup_fee       :decimal(12, 2)
#  business_open           :string
#  business_close          :string
#

require 'rails_helper'

RSpec.describe Region, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
