# frozen_string_literal: true

require 'rails_helper'

RSpec.describe NewWorkerAccount, type: :model do
  context 'validates presence' do
    it { should validate_presence_of(:full_name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:phone) }
    it { should validate_presence_of(:password) }
    it { should validate_presence_of(:password_confirmation) }
    it { should validate_presence_of(:street_address) }
    it { should validate_presence_of(:city) }
    it { should validate_presence_of(:state) }
    it { should validate_presence_of(:zipcode) }
  end

  context 'validates length' do
    it { should validate_length_of(:full_name).is_at_most(50) }
    it { should validate_length_of(:phone).is_at_most(75) }
  end
end
