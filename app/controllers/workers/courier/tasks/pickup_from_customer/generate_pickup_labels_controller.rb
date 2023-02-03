class Workers::Courier::Tasks::PickupFromCustomer::GeneratePickupLabelsController < ApplicationController
	before_action :authenticate_worker!
	before_action :validate_form!, only: %i[create]

	include Orders::LabelCodes

	layout 'workers/no_nav_layout'

	

	def new
		@order = Order.find(params[:id])
	end

	def create
		@order = Order.find(label_params[:id])
		
		@bag_count = label_params[:bag_count].to_i
		@new_code = generate_unique_label_code
		@new_qr_code = RQRCode::QRCode.new(@new_code)

		@codes = []
		@of_count = 1
		@bag_count.times do |bag|
		@codes.push(
			{
			label_heading: "",
			label_description: "LAUNDRY BAG",
			code: @new_code,
			svg_large: @new_qr_code.as_svg(module_size: 13),
			svg_small: @new_qr_code.as_svg(module_size: 5),
			bag_count: @bag_count,
			of_count: "#{@of_count}of#{@bag_count}",
			detergent: @order.readable_detergent.upcase,
			softener_sheets: @order.readable_softener.upcase
			}
		)
		@of_count += 1
		end

		@washer_label = @codes.first
		@order.save_new_label(@new_code, label_params[:bag_count])
	end

	private

	def label_params
		params.require(:label).permit(:bag_count, :id)
	end

	def validate_form!
		unless label_params[:bag_count].present?
		flash[:notice] = 'You must enter a number of bags to continue.'
		redirect_to new_workers_courier_tasks_pickup_from_customer_generate_pickup_labels_path(id: label_params[:id])
		end
	end
end
