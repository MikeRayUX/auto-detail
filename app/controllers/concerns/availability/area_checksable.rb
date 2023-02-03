# frozen_string_literal: true

module Availability::AreaChecksable
  extend ActiveSupport::Concern

  protected

  FIVE_DIGIT_ZIP_REGEX = /^(\d{5})?$/.freeze

  def is_invalid_zip?(code)
    !code.match(FIVE_DIGIT_ZIP_REGEX) || code.blank?
  end

  def came_from_order_page?
    @zipcode && params[:order_page_token]
 end
end
