class Api::V1::Washers::Activations::TermsOfServicesController < Api::V1::Washers::AuthsController
  include Api::V1::Washers::Tos
  
  # /api/v1/washers/activations/terms_of_services/new GET
  def new
    render json: {
      status: :ok,
      code: 200,
      message: 'success',
      terms_of_service: TERMS_OF_SERVICE
    }
  end

  # '/api/v1/washers/activations/terms_of_services/1' PUT
  def update
    if @current_washer.not_accepted_tos?
      @current_washer.skip_finalized_washer_attributes = true
      @current_washer.accept_tos!

      render json: {
        status: :ok,
        code: 200,
        message: 'tos_accepted'
      }
    else
      render json: {
        status: :ok,
        code: 3000,
        message: 'tos_already_accepted',
        errors: 'This section has already been completed.'
      }
    end
  end
  
end