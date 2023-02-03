# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CoverageArea, type: :model do
  context 'with invalid attributes' do
    it 'requires presence of zipcode' do
      @entry = CoverageArea.new(
        state: 'washington',
        county: 'king',
        city: 'seattle'
      ).save

      expect(@entry).to eq(false)
    end

    it 'requires presence of state' do
      @entry = CoverageArea.new(
        zipcode: '11111',
        county: 'king',
        city: 'seattle'
      ).save

      expect(@entry).to eq(false)
    end

    it 'requires presence of county' do
      @entry = CoverageArea.new(
        zipcode: '11111',
        city: 'seattle',
        state: 'washington'
      ).save

      expect(@entry).to eq(false)
    end

    it 'requires presence of city' do
      @entry = CoverageArea.new(
        zipcode: '11111',
        county: 'king',
        state: 'washington'
      ).save

      expect(@entry).to eq(false)
    end
  end

  context 'test callback methods' do
    it 'should downcase attributes before saving' do
      @entry = CoverageArea.new(
        zipcode: '11111',
        county: 'king',
        state: 'washington',
        city: 'seattle'
      )
      # test the callback method :downcase_email :before_save
      # expect(@entry).to receive(:downcase_attributes)
      @entry.save
    end
  end

  context 'validates presence' do
    it { should validate_presence_of(:zipcode) }
    it { should validate_presence_of(:state) }
    it { should validate_presence_of(:county) }
    it { should validate_presence_of(:city) }
  end

  context 'validates length' do
    it { should validate_length_of(:zipcode).is_at_most(50) }
    it { should validate_length_of(:state).is_at_most(50) }
    it { should validate_length_of(:county).is_at_most(50) }
    it { should validate_length_of(:city).is_at_most(50) }
  end
end

# == Schema Information
#
# Table name: coverage_areas
#
#  id         :bigint           not null, primary key
#  zipcode    :string
#  state      :string
#  county     :string
#  city       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

