# frozen_string_literal: true

# == Schema Information
#
# Table name: addresses
#
#  id                 :bigint           not null, primary key
#  user_id            :bigint
#  unit_number        :string
#  city               :string
#  state              :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  zipcode            :string
#  street_address     :string
#  worker_id          :integer
#  latitude           :float
#  longitude          :float
#  partner_id         :integer
#  pick_up_directions :string
#  region_id          :bigint
#  client_id          :bigint
#  phone              :string
#  washer_id          :bigint
#

class Address < ApplicationRecord
  attr_accessor :skip_geocode
  
  geocoded_by :address, unless: :skip_geocode
  after_validation :geocode, unless: :skip_geocode

  belongs_to :worker, optional: true
  belongs_to :washer, optional: true
  belongs_to :user, optional: true
  belongs_to :region, optional: true
  belongs_to :client, optional: true
  has_many :commercial_pickups

  before_save :downcase_attributes

  has_many :commercial_pickups

  validates :street_address, presence: true, length: {
    maximum: 75
  }

  validates :unit_number,
            length: {
              maximum: 20
            }

  validates :city, presence: true, length: {
    maximum: 100
  }
    
  validates :state, presence: true, length: {
    maximum: 100
  }

  validates :zipcode, presence: true, length: { minimum: 5, maximum: 5 }

  def address
    [street_address, city, state, zipcode].compact.join(', ')
  end

  def lat_lng
    [latitude, longitude].compact.join('/')
  end

  def tax_rate
    if self.region.present?
      self.region.tax_rate
    else
      0.085
    end
  end

  def full_address
    if unit_number.present?
        [street_address, "##{unit_number}", city, state, zipcode].compact.join(', ')
    else
        [street_address, city, state, zipcode].compact.join(', ')
    end
  end

  def readable_pickup_directions
    pick_up_directions.present? ? "#{pick_up_directions.upcase}": "None"
  end

  def truncated_street_address(max)
    if street_address.length > max
      "#{street_address[0...max]}...".upcase
    else
      street_address.upcase
    end
  end
  
  def formatted_phone
    ApplicationHelper::Helpers.number_to_phone(phone, area_code: true)
  end

  def within_coverage_area?
    CoverageArea.where(zipcode: zipcode).any?
  end
  
  def outside_coverage_area?
    CoverageArea.where(zipcode: zipcode).none?
	end
	
	def attempt_region_attach
    @coverage_area = CoverageArea.find_by(zipcode: self.zipcode)
		if @coverage_area
			self.update_attribute(:region_id, @coverage_area.region.id)
		else
			self.update_attribute(:region_id, nil)
		end
  end

  def self.find_and_link_regions
    if Address.any?
      Address.all.each do |a|
        a.attempt_region_attach
      end
    end
  end
  
  def google_nav_link
    formatted_link = []
    self.address.split(', ').each do |r|
      formatted_link.push(r.split(' ').join('+'))
    end

    @link = "https://www.google.com/maps/dir//#{formatted_link.join(',')}"
  end

  def create_pickup_for_today!
    @client = self.client
    commercial_pickups.create!(
      client_id: @client.id,
      client_price_per_pound: @client.price_per_pound,
      pick_up_window: @client.pickup_window,
      reference_code: CommercialPickup.new_reference_code,
      pick_up_date: Date.today.strftime,
      full_address: full_address,
      pick_up_directions: pick_up_directions,
      routable_address: address,
      detergent: 'hypoallergenic',
      softener: 'hypo_allergenic'
    )
  end

  def miles_away(origin)
    if origin[:lat].present? && 
       origin[:lng].present? && 
       self.latitude.present? && 
       self.longitude.present?
       
      "#{Geocoder::Calculations.distance_between(
        [origin[:lat], origin[:lng]], 
        [self.latitude, self.longitude]
      ).round(2)} mi"
    else
      "Unknown"
    end
  end

  private

  def downcase_attributes
    self.street_address = street_address.downcase
    self.city = city.downcase
    self.state = state.downcase
  end
end
