# frozen_string_literal: true

module Workers::Courier::Tasks::ExistingScannable
  extend ActiveSupport::Concern

  protected

  # def codes_match_existing_order?
  #   @codes_match = false

  #   if @required_codes.length == @scanned_codes.length
  #     @required_codes.each do |required|
  #       @scanned_codes.each do |scanned|
  #         @codes_match = required == scanned
  #       end
  #     end
  #     return @codes_match
  #   else
  #     return false
  #   end
  # end


  def get_scanned_code(params)
    params[:bags_code].present? ? params[:bags_code] : params[:manually_entered_code]
  end

  def codes_match?(scanned_code, required_code)
    scanned_code == required_code 
  end
end
