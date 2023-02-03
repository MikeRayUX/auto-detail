# frozen_string_literal: true

# == Schema Information
#
# Table name: partner_locations
#
#  id                    :bigint           not null, primary key
#  street_address        :string
#  zipcode               :string
#  state                 :string
#  city                  :string
#  unit_number           :string
#  region                :string
#  latitude              :float
#  longitude             :float
#  services_offered      :string
#  price_per_lb          :decimal(12, 2)
#  turnaround_time_hours :integer
#  business_name         :string
#  business_phone        :string
#  business_email        :string
#  business_website      :string
#  contact_name          :string
#  contact_phone         :string
#  contact_email         :string
#  monday_hours          :string
#  tuesday_hours         :string
#  wednesday_hours       :string
#  thursday_hours        :string
#  friday_hours          :string
#  saturday_hours        :string
#  sunday_hours          :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#


class PartnerLocation < ApplicationRecord
  geocoded_by :address
  after_validation :geocode

  has_many :orders
  has_many :commercial_pickups

  attr_accessor :has_count

  VALID_ZIP_CODE_REGEX = /\A\d{5}-\d{4}|\A\d{5}\z/.freeze
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i.freeze

  validates :street_address, length: {
    maximum: 100
  }
  validates :zipcode, length: {
    maximum: 5
  }
  validates :state, length: {
    maximum: 50
  }
  validates :unit_number, length: {
    maximum: 50
  }

  validates :services_offered, length: {
    maximum: 255
  }

  validates :business_name, presence: true

  validates :business_phone, length: {
    maximum: 10
  }

  validates :business_email, length: {
    maximum: 255
  }

  validates :contact_name, length: {
    maximum: 75
  }

  validates :contact_phone, length: {
    maximum: 10
  }

  validates :contact_email, length: {
    maximum: 255
  }

  # hours
  validates :monday_hours, length: {
    maximum: 50
  }
  validates :tuesday_hours, length: {
    maximum: 50
  }
  validates :wednesday_hours, length: {
    maximum: 50
  }
  validates :thursday_hours, length: {
    maximum: 50
  }
  validates :friday_hours, length: {
    maximum: 50
  }
  validates :saturday_hours, length: {
    maximum: 50
  }
  validates :sunday_hours, length: {
    maximum: 50
  }

  def business_hours
    [monday_hours, tuesday_hours, wednesday_hours, thursday_hours, friday_hours, saturday_hours, sunday_hours].compact.join(', ')
  end

  def address
    [street_address, city, state, zipcode].compact.join(', ')
  end

  def full_address
    [street_address, unit_number, city, state, zipcode].compact.join(', ')
  end

  def formatted_business_phone
    ApplicationHelper::Helpers.number_to_phone(business_phone, area_code: true)
  end

  def google_nav_link
    formatted_link = []

    address.split(',').each do |r|
      formatted_link.push(r.split(' ').join('+'))
    end
    # second slash is required to have the address be the destination instead of the origin
    @link = "https://www.google.com/maps/dir//#{formatted_link.join(',')}"
  end
end
