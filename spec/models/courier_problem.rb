# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CourierProblem, type: :model do
  context 'validates presence' do
    it { should validate_presence_of(:order_id) }
    it { should validate_presence_of(:worker_id) }
    it { should validate_presence_of(:occured_during_task) }
    it { should validate_presence_of(:occured_during_step) }
    it { should validate_presence_of(:problem_encountered) }
  end

  context 'validates length' do
    it { should validate_length_of(:address).is_at_most(100) }
  end
end

# == Schema Information
#
# Table name: courier_problems
#
#  id                  :bigint           not null, primary key
#  order_id            :bigint
#  worker_id           :bigint
#  occured_during_task :integer
#  occured_during_step :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  address             :string
#  problem_encountered :integer
#

