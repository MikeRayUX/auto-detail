# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transaction, type: :model do
  context 'validates presence' do
    # it { should validate_presence_of(:order) }
    # it { should validate_presence_of(:user) }
    it { should validate_presence_of(:transaction_type) }
    it { should validate_presence_of(:card_brand) }
    it { should validate_presence_of(:card_exp_month) }
    it { should validate_presence_of(:card_exp_year) }
    it { should validate_presence_of(:card_last4) }
    it { should validate_presence_of(:customer_email) }
    it { should validate_presence_of(:order_reference_code) }
    it { should validate_presence_of(:subtotal) }
    it { should validate_presence_of(:grandtotal) }
  end
end

# == Schema Information
#
# Table name: transactions
#
#  id                   :bigint           not null, primary key
#  order_id             :bigint
#  user_id              :bigint
#  paid                 :integer
#  transaction_type     :integer
#  stripe_customer_id   :string
#  card_brand           :string
#  card_exp_month       :string
#  card_exp_year        :string
#  card_last4           :string
#  customer_email       :string
#  order_reference_code :string
#  subtotal             :decimal(12, 2)
#  tax                  :decimal(12, 2)
#  grandtotal           :decimal(12, 2)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  stripe_response      :string
#  stripe_charge_id     :string
#  retries              :integer          default(0)
#

