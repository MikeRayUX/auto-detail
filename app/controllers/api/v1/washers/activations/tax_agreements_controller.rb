class Api::V1::Washers::Activations::TaxAgreementsController < Api::V1::Washers::AuthsController
  include Api::V1::Washers::TaxAgreement
  
  # /api/v1/washers/activations/tax_agreements/new GET
  # new_api_v1_washers_activations_tax_agreement_path
  def new
    render json: {
      status: :ok,
      code: 200,
      message: 'success',
      tax_agreement: TAX_AGREEMENT
    }
  end

  # '/api/v1/washers/activations/tax_agreements/1' PUT
  # api_v1_washers_activations_tax_agreement_path
  def update
    if @current_washer.not_accepted_tax_agreement?
      @current_washer.skip_finalized_washer_attributes = true
      @current_washer.accept_tax_agreement!

      render json: {
        status: :ok,
        code: 200,
        message: 'tax_agreement_accepted'
      }
    else
      render json: {
        status: :ok,
        code: 3000,
        message: 'tax_agreement_already_accepted',
        errors: 'This section has already been completed.'
      }
    end
  end
  
end