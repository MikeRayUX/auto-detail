class Workers::Courier::Tasks::Commercial::PickupFromClientsController < ApplicationController
  before_action :authenticate_worker!
  layout 'workers/no_nav_layout'

  include Orders::LabelCodes

  # workers_courier_tasks_commercial_pickup_from_clients_path GET
  def show
    @pickup = CommercialPickup.find(params[:id])
    @client = @pickup.client
    if @pickup.startable?
      @new_code = generate_unique_label_code

      @new_qr_code = RQRCode::QRCode.new(@new_code)

      @label = {
        label_heading: "",
        label_description: "LAUNDRY BAG",
        code: @new_code,
        svg_large: @new_qr_code.as_svg(module_size: 13),
        svg_small: @new_qr_code.as_svg(module_size: 5)
      }
    else
      redirect_to workers_dashboards_open_appointments_path, flash: {
        notice: 'Cannot start, either cancelled or removed.'
      }
    end
  end

  # workers_courier_tasks_commercial_pickup_from_clients_path put
  def update
    @pickup = CommercialPickup.find(params[:id])

    @pickup.save_new_label(params[:qr_code], params[:bag_count])

    @pickup.mark_picked_up

    redirect_to workers_dashboards_open_appointments_path, flash: {
      notice: 'Pickup was successful!'
    }
  end
end