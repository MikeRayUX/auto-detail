class Api::V1::Washers::Activations::EligibilitiesController < Api::V1::Washers::AuthsController
  include Api::V1::Washers::EligibilityQuestions
  
  # /api/v1/washers/activations/eligibilities/new GET
  def new
    @regions = Region.with_washer_capacity.select(:id, :area)

    if @regions.any?
      render json: {
        status: :ok,
        code: 200,
        message: 'regions_available',
        regions: @regions,
        eligibility_questions: ELIGIBILITY_QUESTIONS,
      }
    else
      render json: {
        status: :ok,
        code: 200,
        message: 'no_available_regions',
        errors: "We're sorry, there are no open Washer opportunities at the moment. Please check back later",
      }
    end
  end

  # '/api/v1/washers/activations/eligibilities/1' PUT
  def update
    @region = Region.find(eligibility_params[:region_id])

    if @current_washer&.not_completed_eligibility_application? && @region
      @current_washer.skip_finalized_washer_attributes = true
      @current_washer.complete_eligibility_application!

      @current_washer.update_attribute(:region_id, @region.id)
      render json: {
        status: :ok,
        code: 200,
        message: 'application_submitted'
      }
    else
      render json: {
        status: :ok,
        code: 3000,
        message: 'already_submitted',
        errors: 'This section has already been completed.'
      }
    end
  end

  private
  def eligibility_params
    params.require(:eligibility).permit(%i[
      region_id
      question_answers
    ])
  end
  
end