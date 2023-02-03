# frozen_string_literal: true

# == Schema Information
#
# Table name: availability_mailing_lists
#
#  id         :bigint           not null, primary key
#  zipcode    :string
#  email      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  subscribed :boolean          default(TRUE)
#

require 'test_helper'

class AvailabilityMailingListTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
