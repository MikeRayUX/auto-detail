# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id                        :bigint           not null, primary key
#  email                     :string           default(""), not null
#  encrypted_password        :string           default(""), not null
#  reset_password_token      :string
#  reset_password_sent_at    :datetime
#  remember_created_at       :datetime
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  card_brand                :string
#  card_exp_month            :string
#  card_exp_year             :string
#  card_last4                :string
#  stripe_customer_id        :string
#  phone                     :string
#  full_name                 :string
#  deleted_at                :datetime
#  sms_enabled               :boolean          default(TRUE)
#  promotional_emails        :boolean          default(TRUE)
#  business_review_left      :boolean          default(FALSE)
#  stripe_subscription_id    :string
#  subscription_activated_at :datetime
#  subscription_expires_at   :datetime
#  otp_secret_key            :string
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
