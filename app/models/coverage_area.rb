# frozen_string_literal: true

# == Schema Information
#
# Table name: coverage_areas
#
#  id         :bigint           not null, primary key
#  zipcode    :string
#  state      :string
#  county     :string
#  city       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  region_id  :bigint
#

class CoverageArea < ApplicationRecord
  before_save :downcase_attributes
	
	belongs_to :region, optional: true

  validates :zipcode, presence: true, uniqueness: true, length: { minimum: 5, maximum: 5 }
  validates :state, presence: true, length: { maximum: 50 }
  validates :county, presence: true, length: { maximum: 50 }
  validates :city, presence: true, length: { maximum: 50 }

  def google_search_link
    "https://www.google.com/maps/place/#{zipcode}/"
  end

  def within_region?
    region.present?
  end

  private

  def downcase_attributes
    self.zipcode = zipcode.downcase
    self.state = state.downcase
    self.county = county.downcase
    self.city = city.downcase
  end
end
