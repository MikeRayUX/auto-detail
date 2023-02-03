# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PartnerLocation, type: :model do
  context 'validates presence' do
    it { should validate_presence_of(:business_name) }
  end

  context 'validates length' do
    it { should validate_length_of(:street_address).is_at_most(100) }
    it { should validate_length_of(:zipcode).is_at_most(5) }
    it { should validate_length_of(:state).is_at_most(50) }
    it { should validate_length_of(:unit_number).is_at_most(50) }
    it { should validate_length_of(:services_offered).is_at_most(255) }
    it { should validate_length_of(:services_offered).is_at_most(255) }
    it { should validate_length_of(:business_phone).is_at_most(10) }
    it { should validate_length_of(:business_email).is_at_most(255) }
    it { should validate_length_of(:contact_name).is_at_most(75) }
    it { should validate_length_of(:contact_phone).is_at_most(10) }
    it { should validate_length_of(:contact_email).is_at_most(255) }
    it { should validate_length_of(:monday_hours).is_at_most(50) }
    it { should validate_length_of(:tuesday_hours).is_at_most(50) }
    it { should validate_length_of(:wednesday_hours).is_at_most(50) }
    it { should validate_length_of(:thursday_hours).is_at_most(50) }
    it { should validate_length_of(:friday_hours).is_at_most(50) }
    it { should validate_length_of(:saturday_hours).is_at_most(50) }
    it { should validate_length_of(:sunday_hours).is_at_most(50) }
  end
end

# == Schema Information
#
# Table name: partner_locations
#
#  id                    :bigint           not null, primary key
#  street_address        :string
#  zipcode               :string
#  state                 :string
#  city                  :string
#  unit_number           :string
#  region                :string
#  latitude              :float
#  longitude             :float
#  services_offered      :string
#  price_per_lb          :decimal(12, 2)
#  turnaround_time_hours :integer
#  business_name         :string
#  business_phone        :string
#  business_email        :string
#  business_website      :string
#  contact_name          :string
#  contact_phone         :string
#  contact_email         :string
#  monday_hours          :string
#  tuesday_hours         :string
#  wednesday_hours       :string
#  thursday_hours        :string
#  friday_hours          :string
#  saturday_hours        :string
#  sunday_hours          :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

