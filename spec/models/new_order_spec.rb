# == Schema Information
#
# Table name: new_orders
#
#  id                           :bigint           not null, primary key
#  user_id                      :bigint
#  washer_id                    :bigint
#  region_id                    :bigint
#  ref_code                     :string
#  detergent                    :integer
#  softener                     :integer
#  bag_count                    :integer
#  scheduled                    :datetime
#  picked_up_at                 :datetime
#  delivered_at                 :datetime
#  est_delivery                 :datetime
#  tax_rate                     :float
#  subtotal                     :decimal(12, 2)
#  tax                          :decimal(12, 2)
#  grandtotal                   :decimal(12, 2)
#  tip                          :decimal(12, 2)
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  address                      :string
#  unit_number                  :string
#  directions                   :string
#  accept_by                    :datetime
#  accepted_at                  :datetime
#  cancelled_at                 :datetime
#  completed_at                 :datetime
#  stripe_charge_id             :string
#  washer_pay                   :decimal(12, 2)
#  profit                       :decimal(12, 2)
#  zipcode                      :string
#  customer_rating              :integer
#  enroute_for_pickup_at        :datetime
#  arrived_for_pickup_at        :datetime
#  status                       :integer          default("created")
#  full_address                 :string
#  address_lat                  :float
#  address_lng                  :float
#  pickup_type                  :integer
#  bag_codes                    :string
#  wash_notes                   :string
#  washer_final_pay             :decimal(12, 2)
#  washer_ppb                   :decimal(12, 2)
#  stripe_transfer_id           :string
#  stripe_transfer_error        :string
#  payout_desc                  :string
#  readable_delivered_at        :string
#  est_pickup_by                :datetime
#  stripe_refund_id             :string
#  pmt_processing_fee           :decimal(12, 2)
#  washer_adjusted_bag_count_at :datetime
#  refunded_amount              :decimal(12, 2)
#  delivery_location            :integer
#  delivery_photo_base64        :string
#  washer_pay_percentage        :float
#  failed_pickup_fee            :decimal(12, 2)
#  bag_price                    :decimal(12, 2)
#

require 'rails_helper'

RSpec.describe NewOrder, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
