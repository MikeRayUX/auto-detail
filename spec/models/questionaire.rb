# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Questionaire, type: :model do
  # context "validates presence" do
  #   it { should validate_presence_of(:subject) }
  # end

  # context "validates length" do
  #   it { should validate_length_of(:elaboration).is_at_most(255)}
  # end
end

# == Schema Information
#
# Table name: questionaires
#
#  id               :bigint           not null, primary key
#  user_id          :bigint
#  subject          :integer
#  answer_selection :string
#  elaboration      :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

