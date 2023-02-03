# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkerAccountCreationCode, type: :model do
  context 'validates presence' do
    it { should validate_presence_of(:code) }
  end

  context 'validates length' do
    it { should validate_length_of(:code).is_at_most(20) }
  end
end

# == Schema Information
#
# Table name: worker_account_creation_codes
#
#  id         :bigint           not null, primary key
#  code       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

