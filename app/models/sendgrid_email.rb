# == Schema Information
#
# Table name: sendgrid_emails
#
#  id              :bigint           not null, primary key
#  template_id     :string
#  description     :string
#  preview_url     :string
#  content_summary :text
#  category        :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class SendgridEmail < ApplicationRecord
  has_many :email_sends

  validates :template_id, presence: true
  validates :description, presence: true
  validates :preview_url, presence: true
  validates :content_summary, presence: true
  validates :category, presence: true

  enum category: %i[
    customer_promotion
    customer_announcement
    washer_promotion
    washer_announcement
  ]

  def readable_category
    category.split('_').join(' ').titleize
  end
end
