class Api::V1::Washers::Activations::InsuranceAgreementsController < Api::V1::Washers::AuthsController
  include Api::V1::Washers::InsuranceAgreement
  
  # /api/v1/washers/activations/insurance_agreements/new GET
  # new_api_v1_washers_activations_insurance_agreement_path
  def new
    render json: {
      status: :ok,
      code: 200,
      message: 'success',
      insurance_agreement: INSURANCE_AGREEMENT
    }
  end

  # '/api/v1/washers/activations/insurance_agreements/1' PUT
  # api_v1_washers_activations_insurance_agreement_path
  def update
    if @current_washer.not_accepted_insurance_agreement?
      @current_washer.skip_finalized_washer_attributes = true
      @current_washer.accept_insurance_agreement!

      render json: {
        status: :ok,
        code: 200,
        message: 'insurance_agreement_accepted'
      }
    else
      render json: {
        status: :ok,
        code: 3000,
        message: 'insurance_agreement_already_accepted',
        errors: 'This section has already been completed.'
      }
    end
  end
  
end