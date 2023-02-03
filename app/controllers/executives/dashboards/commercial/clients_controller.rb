class Executives::Dashboards::Commercial::ClientsController < ApplicationController
  before_action :authenticate_executive!

  layout 'executives/dashboard_layout', only: %i[index show edit]

  # executives_dashboards_commercial_client_path GET
  def show
    @client = Client.find(params[:id])
    @addresses = @client.addresses
  end
  
  # executives_dashboards_commercial_client_path PUT
  def update
    @client = Client.find(params[:id])
    if @client.update_attributes!(client_params)
      redirect_to executives_dashboards_commercial_client_path(id: @client.id), flash: {
        notice: 'Client Updated Successfully!'
      }
    else
      redirect_to executives_dashboards_commercial_client_path(id: @client.id), flash: {
        notice: @client.errors.full_messages.first
      }
    end
  end

  # executives_dashboards_commercial_client_path DELETE
  def destroy
  end

  # edit_executives_dashboards_commercial_client_path 
  def edit
  end

  # executives_dashboards_commercial_clients_path GET
  def index
    @clients = Client.all
  end

  private

  def client_params
    params.require(:client).permit(%i[
      name
      phone
      email
      special_notes
      contact_person
      area_of_business
      monday
      tuesday
      wednesday
      thursday
      friday
      saturday
      sunday
      pickup_window
      price_per_pound
    ])
  end

  def new_client_params
    params.require(:new_client).permit(%i[
      name
      phone
      email
      special_notes
      contact_person
      area_of_business
      monday
      tuesday
      wednesday
      thursday
      friday
      saturday
      sunday
      pickup_window
      price_per_pound
      address_count
      address_street_address_0
      address_unit_number_0
      address_city_0
      address_state_0
      address_zipcode_0
      address_pick_up_directions_0
      address_phone_0
      address_street_address_1
      address_unit_number_1
      address_city_1
      address_state_1
      address_zipcode_1
      address_pick_up_directions_1
      address_phone_1
      address_street_address_2
      address_unit_number_2
      address_city_2
      address_state_2
      address_zipcode_2
      address_pick_up_directions_2
      address_phone_2
      address_street_address_3
      address_unit_number_3
      address_city_3
      address_state_3
      address_zipcode_3
      address_pick_up_directions_3
      address_phone_3
      address_street_address_4
      address_unit_number_4
      address_city_4
      address_state_4
      address_zipcode_4
      address_pick_up_directions_4
      address_phone_4
      address_street_address_5
      address_unit_number_5
      address_city_5
      address_state_5
      address_zipcode_5
      address_pick_up_directions_5
      address_phone_5
      address_street_address_6
      address_unit_number_6
      address_city_6
      address_state_6
      address_zipcode_6
      address_pick_up_directions_6
      address_phone_6
      address_street_address_7
      address_unit_number_7
      address_city_7
      address_state_7
      address_zipcode_7
      address_pick_up_directions_7
      address_phone_7
      address_street_address_8
      address_unit_number_8
      address_city_8
      address_state_8
      address_zipcode_8
      address_pick_up_directions_8
      address_phone_8
      address_street_address_9
      address_unit_number_9
      address_city_9
      address_state_9
      address_zipcode_9
      address_pick_up_directions_9
      address_phone_9
      ])
  end

  def card_params
    params.require(:card).permit(%i[
      stripe_token
      card_brand
      card_exp_month
      card_exp_year
      card_last4
      ])
  end

end