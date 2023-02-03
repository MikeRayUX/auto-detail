# == Schema Information
#
# Table name: subscriptions
#
#  id                :bigint           not null, primary key
#  stripe_product_id :string
#  stripe_price_id   :string
#  price             :decimal(12, 2)
#  name              :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

require 'rails_helper'

RSpec.describe Subscription, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
