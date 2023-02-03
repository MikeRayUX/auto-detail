# frozen_string_literal: true

class StaticPages::HomePagesController < ApplicationController
  layout 'static_pages/static_pages_layout'

  def show
    @region = Region.first
    
    @cities1 = [
      'Seattle',
      'White Center',
      'Burien',
      'Renton',
    ]
    @cities2 = [
      'Sea Tac',
      'Tukwila',
    ]
    @cities3 = [
      'Mercer Island',
      'Medina'
		]

    @business_phone = '(206)414-9538'

    @banner = SiteBanner.find_by(display_location: 'landing')
  end
end
