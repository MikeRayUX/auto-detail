class StaticPages::CommercialPagesController < ApplicationController

  layout 'static_pages/no_nav_layout'

  def show
    @contact_phone = '(206)414-9538'
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
    ]
    
    # @banner = SiteBanner.new(
    #   display_location: 'landing',
    #   body_text: '25% off until Sept. 1st',
    #   link_text: 'asdfasdf',
    #   link_url: 'root_path'
    # )
  end

end
