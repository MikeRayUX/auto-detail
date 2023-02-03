# == Schema Information
#
# Table name: clients
#
#  id                 :bigint           not null, primary key
#  name               :string
#  email              :string
#  special_notes      :string
#  contact_person     :string
#  area_of_business   :string
#  pickup_window      :integer
#  card_brand         :string
#  card_exp_month     :string
#  card_exp_year      :string
#  card_last4         :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  price_per_pound    :decimal(12, 2)
#  phone              :string
#  stripe_customer_id :string
#  monday             :boolean          default(FALSE)
#  tuesday            :boolean          default(FALSE)
#  wednesday          :boolean          default(FALSE)
#  thursday           :boolean          default(FALSE)
#  friday             :boolean          default(FALSE)
#  saturday           :boolean          default(FALSE)
#  sunday             :boolean          default(FALSE)
#  active             :boolean          default(TRUE)
#

require 'rails_helper'

RSpec.describe Client, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
