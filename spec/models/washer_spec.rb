# == Schema Information
#
# Table name: washers
#
#  id                              :bigint           not null, primary key
#  email                           :string           default(""), not null
#  encrypted_password              :string           default(""), not null
#  reset_password_token            :string
#  reset_password_sent_at          :datetime
#  remember_created_at             :datetime
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  first_name                      :string
#  middle_name                     :string
#  last_name                       :string
#  region_id                       :bigint
#  encrypted_ssn                   :string
#  encrypted_ssn_iv                :string
#  encrypted_date_of_birth         :string
#  encrypted_date_of_birth_iv      :string
#  encrypted_phone                 :string
#  encrypted_phone_iv              :string
#  deactivated_at                  :datetime
#  activated_at                    :datetime
#  otp_secret_key                  :string
#  authenticate_with_otp           :boolean          default(TRUE)
#  encrypted_drivers_license       :string
#  encrypted_drivers_license_iv    :string
#  completed_app_intro_at          :datetime
#  tos_accepted_at                 :datetime
#  eligibility_completed_at        :datetime
#  background_check_submitted_at   :datetime
#  stripe_account_id               :string
#  tax_agreement_accepted_at       :datetime
#  background_check_approved_at    :datetime
#  insurance_agreement_accepted_at :datetime
#  full_name                       :string
#  last_online_at                  :datetime
#  current_lat                     :float
#  current_lng                     :float
#  payoutable_as_ic                :boolean          default(TRUE)
#  live_within_region              :boolean
#  min_age                         :boolean
#  legal_to_work                   :boolean
#  valid_drivers_license           :boolean
#  valid_car_insurance_coverage    :boolean
#  valid_ssn                       :boolean
#  reliable_transportation         :boolean
#  can_lift_30_lbs                 :boolean
#  has_disability                  :boolean
#  has_equipment                   :boolean
#  consent_to_background_check     :boolean
#  app_invitation_sent_at          :datetime
#

require 'rails_helper'

RSpec.describe Washer, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
