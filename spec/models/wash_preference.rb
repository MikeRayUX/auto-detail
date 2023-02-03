# frozen_string_literal: true

# == Schema Information
#
# Table name: user_preferences
#
#  id               :bigint           not null, primary key
#  user_id          :bigint
#  sms_enabled      :boolean          default(TRUE)
#  marketing_emails :boolean          default(TRUE)
#  detergent_option :integer
#  wash_temp        :integer
#  bleach_on_whites :boolean
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

require 'rails_helper'

RSpec.describe WashPreference, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
