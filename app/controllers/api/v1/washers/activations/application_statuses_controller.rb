# frozen_string_literal: true

class Api::V1::Washers::Activations::ApplicationStatusesController < Api::V1::Washers::AuthsController

  # /api/v1/washers/activations/application_statuses GET
  def index
    @w = @current_washer

    render json: {
      status: :ok,
      code: 200,
      message: 'status_returned',
      application: {
        washer: {
          full_name: @w.full_name.upcase,
          email: @w.email
        },
        introductions: @w.app_intro_status,
        terms_of_services: @w.tos_status,
        eligibilities: @w.eligibility_application_status,
        background_checks: @w.background_check_status,
        insurances: @w.insurance_agreement_status,
        tax_agreements: @w.tax_agreement_status,
        direct_deposits: @w.stripe_account_status,
      },
    }
  end
  
end
