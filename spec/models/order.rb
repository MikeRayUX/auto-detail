# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Order, type: :model do
  # context "validates length" do
  #   it {should validate_length_of(:special_notes).is_at_most(255)}

  # end
  # context "validates presence" do
  #   it { should validate_presence_of(:detergent_preference) }
  # end
end

# == Schema Information
#
# Table name: orders
#
#  id                                      :bigint           not null, primary key
#  user_id                                 :bigint
#  order_total                             :decimal(12, 2)
#  final_weight                            :float
#  created_at                              :datetime         not null
#  updated_at                              :datetime         not null
#  reference_code                          :string
#  pick_up_time                            :string
#  worker_id                               :integer
#  full_address                            :string
#  customer_lat                            :float
#  customer_long                           :float
#  pick_up_date                            :datetime
#  bags_code                               :string
#  bags_collected                          :integer
#  picked_up_from_customer_at              :datetime
#  dropped_off_to_partner_at               :datetime
#  picked_up_from_partner_at               :datetime
#  delivered_to_customer_at                :datetime
#  courier_weight                          :float
#  partner_reported_weight                 :float
#  global_status                           :integer          default("created")
#  pick_up_from_customer_status            :integer          default("pick_up_from_customer_not_started")
#  drop_off_to_partner_status              :integer          default("drop_off_to_partner_not_started")
#  partner_location_id                     :integer
#  marked_as_ready_for_pickup_from_partner :boolean          default(FALSE)
#  pick_up_from_partner_status             :integer          default("pick_up_from_partner_not_started")
#  partner_invoice_number                  :string
#  partner_grand_total                     :decimal(12, 2)
#  deliver_to_customer_status              :integer          default("delivery_to_customer_not_started")
#  courier_stated_delivered_location       :string
#  delivery_attempts                       :integer          default(0)
#  checkout_holding_order_status           :integer
#  under_minimum_weight                    :boolean          default(FALSE)
#  routable_address                        :string
#  detergent                               :integer
#  bleach                                  :integer
#  softener                                :integer
#

