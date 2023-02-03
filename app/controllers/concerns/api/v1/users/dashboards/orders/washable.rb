# frozen_string_literal: true

module Api::V1::Users::Dashboards::Orders::Washable
  extend ActiveSupport::Concern
  
  protected

  def get_user_wash_preference
    @preference = @current_user.wash_preference

    @preferred_detergent = OPTIONS_FOR_SELECT[:detergents_for_select].find { |det| det[:value] === @preference.detergent }
    @preferred_wash_temp = OPTIONS_FOR_SELECT[:temps_for_select].find { |temp| temp[:value] === @preference.wash_temp }

    @bleach_on_whites = {
      value: @preference.use_bleach_on_whites,
      readable: @preference.use_bleach_on_whites ? 'Yes' : 'No'
    }
  end
end
