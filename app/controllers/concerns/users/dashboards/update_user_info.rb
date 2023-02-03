# frozen_string_literal: true

module Users::Dashboards::UpdateUserInfo
  extend ActiveSupport::Concern

  protected

  # def get_flash(info_type)
  #   case info_type
  #   when 'pickup_directions'
  #     flash[:success] = 'Updated Successfully'
  #   when 'address'
  #     flash[:success] = 'Address updated successfully! Your new address will be used for your next order. Or if you currently have an order to be reattempted for delivery.'
  #   end
  # end

  # def info_is_new?(record, params)
  #   record.assign_attributes(params)
  #   record.changed?
  # end

  # def get_previously_used_user_info(record, info_type)
  #   case info_type
  #   when 'name'
  #     record.full_name
  #   when 'phone number'
  #     ApplicationHelper::Helpers.number_to_phone(record.phone, area_code: true)
  #   when 'address'
  #     "
  #     #{record.street_address.upcase}
  #     #{record.unit_number.upcase}
  #     #{record.city.upcase}
  #     #{record.state.upcase}
  #     #{record.zipcode.upcase}
  #     "
  #   when 'email'
  #     record.email
  #   end
  # end

  # def update_order_addresses_scheduled_for_redelivery(user, address)
  #   @redeliveries = user.orders.redeliveries

  #   if @redeliveries.any?
  #     @redeliveries.update_all(
  #       full_address: address.full_address,
  #       routable_address: address.address
  #     )
  #   end
  # end

  def send_update_info_notification_email(user_id, info_type)
    if info_type == 'password'
      @timestamp = DateTime.current.strftime('%m/%d/%Y at %I:%M%P')
      Users::Dashboards::Settings::UserUpdatedPasswordMailerWorker.perform_async(user_id, @timestamp)
    end
  end

  def update_stripe_customer_email
    Stripe::Customer.update(
      @user.stripe_customer_id,
      email: email_params[:email]
    )
  rescue Stripe::InvalidRequestError => e
    false
  end

end
