# == Schema Information
#
# Table name: email_sends
#
#  id                :bigint           not null, primary key
#  user_id           :bigint
#  washer_id         :bigint
#  sendgrid_email_id :bigint
#  status            :integer
#  api_errors        :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class EmailSend < ApplicationRecord
  belongs_to :sendgrid_email
  belongs_to :user, optional: true
  belongs_to :washer, optional: true

  validates :status, presence: true

  enum status: %i[
    sent
    failed
  ]
end
