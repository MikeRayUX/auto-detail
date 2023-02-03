# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RegionPricing, type: :model do
  context 'validates presence' do
    it { should validate_presence_of(:region) }
    it { should validate_presence_of(:price_per_pound) }
    it { should validate_presence_of(:tax_rate) }
    it { should validate_presence_of(:minimum_weight) }
    it { should validate_presence_of(:minimum_weight_fee) }
  end
end

# == Schema Information
#
# Table name: region_pricings
#
#  id                 :bigint           not null, primary key
#  region             :string
#  price_per_pound    :decimal(12, 2)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  tax_rate           :float
#  minimum_weight     :integer
#  minimum_weight_fee :decimal(12, 2)
#

