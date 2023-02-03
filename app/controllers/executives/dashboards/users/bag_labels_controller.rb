class Executives::Dashboards::Users::BagLabelsController < ApplicationController
  before_action :authenticate_executive!
  layout 'executives/dashboard_layout'

  # executives_dashboards_users_bag_labels_path
  def create
    @customer = User.find(label_params[:user_id])
    @bag_count = label_params[:count].to_i

    @codes = []

    @bag_count.times do |num|
      @code = SecureRandom.hex(2).upcase
      @new_qr_code = RQRCode::QRCode.new(@code)
      @codes.push(
        {
        code: @code,
        svg_small: @new_qr_code.as_svg(module_size: 9),
        svg_mini: @new_qr_code.as_svg(module_size: 4.5),
        }
      )
    end
  end

  private
  def label_params
    params.require(:label).permit(%i[
      user_id
      count
    ])
  end
  
end
