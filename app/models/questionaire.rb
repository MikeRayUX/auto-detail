# frozen_string_literal: true

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

class Questionaire < ApplicationRecord
  belongs_to :user

  validates :subject, presence: true
  validates :elaboration, length: {
    maximum: 1000
  }

  enum subject: %i[
    account_cancellation
  ]
end
