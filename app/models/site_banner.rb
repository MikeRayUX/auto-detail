# == Schema Information
#
# Table name: site_banners
#
#  id               :bigint           not null, primary key
#  display_location :integer
#  body_text        :string
#  link_text        :string
#  link_url         :string
#  alt_url          :string
#  conditional      :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class SiteBanner < ApplicationRecord
  validates :display_location, presence: true
  validates :body_text, presence: true, length: {
    maximum: 65
  }
  validates :link_text, presence: true
  validates :link_url, presence: true

  enum display_location: %i[
    landing
    customer_dashboard
  ]

end
