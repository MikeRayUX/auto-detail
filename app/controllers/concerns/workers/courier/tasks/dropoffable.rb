# frozen_string_literal: true

module Workers::Courier::Tasks::Dropoffable
  extend ActiveSupport::Concern

  protected

  def get_partner_locations_for_select
    @partner_locations = PartnerLocation.all.sort_by { |loc| loc.business_name }
    @options_for_select = []
    @partner_locations.each do |item|
      @location = "#{item.business_name} | #{item.address}".upcase
      @options_for_select.push([@location, item.id])
    end
  end

end
