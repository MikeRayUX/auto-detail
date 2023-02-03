# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Address, type: :model do
  context 'validates presence' do
    it { should validate_presence_of(:street_address) }
    it { should validate_presence_of(:state) }
    it { should validate_presence_of(:state) }
    it { should validate_presence_of(:zipcode) }
  end

  context 'validates length' do
    it { should validate_length_of(:unit_number).is_at_most(20) }
    it { should validate_length_of(:city).is_at_most(100) }
    it { should validate_length_of(:state).is_at_most(100) }
    it { should validate_length_of(:zipcode).is_at_most(5) }
    it { should validate_length_of(:zipcode).is_at_least(5) }
  end

  context 'private methods' do
    it 'should call downcase_attributes before save' do
      address = build(:address)
      address.street_address.upcase!
      address.unit_number.upcase!
      address.city.upcase!
      address.state.upcase!

      address.save
      expect(address.street_address). to eq address.street_address.downcase
      expect(address.city). to eq address.city.downcase
      expect(address.state). to eq address.state.downcase
    end
  end
end

# == Schema Information
#
# Table name: addresses
#
#  id                 :bigint           not null, primary key
#  user_id            :bigint
#  unit_number        :string
#  city               :string
#  state              :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  zipcode            :string
#  street_address     :string
#  worker_id          :integer
#  latitude           :float
#  longitude          :float
#  partner_id         :integer
#  pick_up_directions :string
#

