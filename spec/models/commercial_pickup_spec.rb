# == Schema Information
#
# Table name: commercial_pickups
#
#  id                                :bigint           not null, primary key
#  transaction_id                    :bigint
#  client_id                         :bigint
#  full_address                      :string
#  routable_address                  :string
#  reference_code                    :string
#  pick_up_directions                :string
#  bags_code                         :string
#  pick_up_window                    :integer
#  detergent                         :integer
#  softener                          :integer
#  global_status                     :integer          default("created")
#  bags_collected                    :integer
#  pick_up_date                      :datetime
#  picked_up_from_client_at          :datetime
#  dropped_off_to_partner_at         :datetime
#  picked_up_from_partner_at         :datetime
#  delivered_to_client_at            :datetime
#  weight                            :decimal(12, 2)
#  paid                              :boolean          default(FALSE)
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  partner_location_id               :bigint
#  problem_encountered               :integer
#  courier_stated_delivered_location :integer
#  address_id                        :bigint
#  subtotal                          :decimal(12, 2)
#  tax                               :decimal(12, 2)
#  grandtotal                        :decimal(12, 2)
#  tax_rate                          :decimal(12, 2)
#  client_price_per_pound            :decimal(12, 2)
#

require 'rails_helper'

RSpec.describe CommercialPickup, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
