# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Appointment, type: :model do
  context 'validates presence' do
    it { should validate_presence_of(:pick_up_date) }
    it { should validate_presence_of(:pick_up_time) }
  end
end

# == Schema Information
#
# Table name: appointments
#
#  id           :bigint           not null, primary key
#  order_id     :bigint
#  pick_up_date :datetime
#  pick_up_time :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

