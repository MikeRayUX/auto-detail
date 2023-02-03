# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  context 'validates presence' do
    it { is_expected.to validate_presence_of(:full_name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:phone) }
    # it { is_expected.to validate_presence_of(:card_brand) }
    # it { is_expected.to validate_presence_of(:card_exp_month) }
    # it { is_expected.to validate_presence_of(:card_exp_year) }
    # it { is_expected.to validate_presence_of(:card_last4) }
  end

  context 'validates length' do
    it { should validate_length_of(:full_name).is_at_most(75) }
    it { should validate_length_of(:phone).is_at_least(10) }
    it { should validate_length_of(:phone).is_at_most(10) }
  end

  context 'model associations' do
    it { should have_many(:orders) }
    it { should have_many(:transactions) }
    it { should have_one(:address) }
  end

  context 'validates uniqueness' do
    it 'should validate email is unique' do
      user = create(:user)
      user2 = build(:user)
      expect(user2.save).to be false
    end
  end

  context 'valid email format' do
    it 'should accept valid email format' do
      valid_email = 'TEST@EXAMPLE.COM'
      user = build(:user)
      user.email = valid_email

      expect(user.save).to eq true
    end

    it 'should reject invalid email format' do
      user = build(:user, :invalid_email)

      expect(user.save).to eq false
    end
  end

  context 'private methods' do
    it 'should call downcase_names before save' do
      user = build(:user)
      user.full_name.upcase!

      user.save
      expect(user.full_name).to eq user.full_name.downcase
    end
  end
end

# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  card_brand             :string
#  card_exp_month         :string
#  card_exp_year          :string
#  card_last4             :string
#  stripe_customer_id     :string
#  phone                  :string
#  full_name              :string
#  deleted_at             :datetime
#  sms_enabled            :boolean          default(TRUE)
#  promotional_emails     :boolean          default(TRUE)
#

