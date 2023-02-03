class Workers::Courier::Tasks::PickupFromPartner::GenerateDeliveryLabelsController < ApplicationController
	before_action :authenticate_worker!
	before_action :validate_form!, only: %i[create]

	layout 'workers/no_nav_layout'

	def new
		@order = Order.find(params[:id])
	end

	def create
		@order = Order.find(label_params[:id])
		@user = @order.user

		@bag_count = label_params[:bag_count].to_i
		@existing_code = @order.bags_code
		@qr_code = RQRCode::QRCode.new(@existing_code)

		@codes = []
		@of_count = 1
		@bag_count.times do |bag|
			@codes.push(
				{
					label_heading: '',
					label_description: "LAUNDRY BAG",
					code: @existing_code,
					svg_large: @qr_code.as_svg(module_size: 10),
					svg_small: @qr_code.as_svg(module_size: 5),
					of_count: "#{@of_count}of#{@bag_count}",
				}
			)
			@of_count += 1
		end

		@order.update_attribute(:bags_collected, label_params[:bag_count])
	end

	private
	def label_params
		params.require(:label).permit(:bag_count, :id)
	end

	def validate_form!
		unless label_params[:bag_count].present?
			flash[:notice] = 'You must enter a number of bags to continue.'
			redirect_to new_workers_courier_tasks_pickup_from_partner_generate_delivery_labels_path(id: label_params[:id])
		end
	end
end
