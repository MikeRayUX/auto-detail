# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Worker, type: :model do
  context 'validates presence' do
    it { is_expected.to validate_presence_of(:full_name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:phone) }
  end

  context 'validates length' do
    it { should validate_length_of(:full_name).is_at_most(75) }
    it { should validate_length_of(:phone).is_at_least(10) }
    it { should validate_length_of(:phone).is_at_most(10) }
  end

  context 'validates uniqueness' do
    it 'should validate email is unique' do
      worker = create(:worker)
      worker2 = build(:worker)

      expect(worker2.save).to be false
    end
  end

  context 'valid email format' do
    it 'should accept valid email format' do
      valid_email = 'test@example.com'
      worker = build(:worker)

      worker.email = valid_email
      expect(worker.save).to eq true
    end

    it 'Should reject invalid email format' do
      worker = build(:worker, :invalid_email)

      expect(worker.save).to eq false
    end
  end
end

# == Schema Information
#
# Table name: workers
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  full_name              :string
#  phone                  :string
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

