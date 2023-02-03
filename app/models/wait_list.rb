# == Schema Information
#
# Table name: wait_lists
#
#  id             :bigint           not null, primary key
#  zipcode        :string
#  email          :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  invite_sent_at :datetime
#

class WaitList < ApplicationRecord
  scope :waiting, -> { where(invite_sent_at: nil) }

  validates :zipcode, presence: true, length: {minimum: 5, maximum: 5}
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }

  
  def within_coverage_area?
    CoverageArea.find_by(zipcode: self.zipcode).present?
  end

  def send_invitation_email!
    Executives::Dashboards::WaitListInvitationMailer.send_email(self).deliver_later
  end

  def region
    CoverageArea.find_by(zipcode: self.zipcode).region
  end
end
