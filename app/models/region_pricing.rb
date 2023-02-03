# frozen_string_literal: true

# == Schema Information
#
# Table name: region_pricings
#
#  id              :bigint           not null, primary key
#  region          :string
#  price_per_pound :decimal(12, 2)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  tax_rate        :float
#  minimum_charge  :decimal(12, 2)
#

class RegionPricing < ApplicationRecord
  has_many :orders
  validates :region, presence: true
  validates :price_per_pound, presence: true
  validates :tax_rate, presence: true
  validates :minimum_charge, presence: true
  validates :price_per_pound, presence: true

  # def readable_minimum_weight_fee
  #   "$#{format('%.2f', minimum_weight_fee)}"
  # end

  def readable_price_per_pound
    "$#{format('%.2f', price_per_pound)}"
  end

  def readable_minimum_charge
    "$#{minimum_charge.to_i}"
  end
end
