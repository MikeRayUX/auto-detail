# frozen_string_literal: true

# == Schema Information
#
# Table name: worker_account_creation_codes
#
#  id         :bigint           not null, primary key
#  code       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#


class WorkerAccountCreationCode < ApplicationRecord
  validates :code, presence: true, length: {
    maximum: 20
  }
end
