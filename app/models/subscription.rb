# == Schema Information
#
# Table name: subscriptions
#
#  id                :bigint           not null, primary key
#  stripe_product_id :string
#  stripe_price_id   :string
#  price             :decimal(12, 2)
#  name              :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Subscription < ApplicationRecord
  validates :name, presence: true
  validates :stripe_product_id, presence: true
  validates :stripe_price_id, presence: true
  validates :price, presence: true

  def tax(tax_rate)
    (price * tax_rate).round(2)
  end

  def grandtotal(tax_rate)
    (price + (price * tax_rate)).round(2)
  end
end
