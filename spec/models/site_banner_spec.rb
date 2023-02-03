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

require 'rails_helper'

RSpec.describe SiteBanner, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
