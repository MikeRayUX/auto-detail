class Clients::AddressesController < ApplicationController
  before_action :authenticate_executive!

  # clients_addresses_path POST
  def create
    @client = Client.find(address_params[:client_id])
    @address = @client.addresses.new(address_params)

    if @address.valid? && @address.within_coverage_area?
      @address.save!
      redirect_to executives_dashboards_commercial_client_path(id: @client.id), flash: {
        notice: 'Address Created!'
      }
    else
      redirect_to executives_dashboards_commercial_client_path(id: @client.id), flash: {
        notice: 'Address is not eligible for service.'
      }
    end
  end

  # clients_addresses_path PUT
  def update
    @address = Address.find(params[:id])
    @client = @address.client

    if @address.update_attributes!(address_params)
      redirect_to executives_dashboards_commercial_client_path(id: @client.id), flash: {
        notice: 'Address Updated Successfully'
      }
    else
      redirect_to executives_dashboards_commercial_client_path(id: @client.id), flash: {
        notice: @address.errors.full_messages.first
      }
    end
  end

  # clients_addresses_path DELETE
  # soft_delete address to halt pickups
  def destroy
    @client = Client.find(params[:client_id])
    @address = @client.addresses.find_by(id: params[:address_id])

    if @address.destroy!
      redirect_to executives_dashboards_commercial_client_path(id: @client.id), flash: {
        notice: 'Address removed'
      }
    else
      redirect_to executives_dashboards_commercial_client_path(id: @client.id), flash: {
        notice: 'Could not remove address'
      }
    end
  end

  private

  def address_params
    params.require(:address).permit(%i[
        street_address
        unit_number
        city
        state
        zipcode
        pick_up_directions
        phone
        client_id
      ]
    )
  end
end
