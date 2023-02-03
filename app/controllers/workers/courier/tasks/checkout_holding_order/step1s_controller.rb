# frozen_string_literal: true

class Workers::Courier::Tasks::CheckoutHoldingOrder::Step1sController < ApplicationController
  before_action :authenticate_worker!

  layout 'workers/no_nav_layout'

  def show
    @order = Order.find_by(reference_code: params[:id])
  end
end
