class Api::V1::Washers::Activations::IntroductionsController < Api::V1::Washers::AuthsController
  include Api::V1::Washers::IntroSlides
  
  # /api/v1/washers/activations/introductions/new GET
  def new
    render json: {
      status: :ok,
      code: 200,
      message: 'success',
      content: INTRO_SLIDES
    }
  end

  # '/api/v1/washers/activations/introductions/1' PUT
  def update
    if @current_washer.not_completed_app_intro?
      @current_washer.skip_finalized_washer_attributes = true
      @current_washer.complete_app_intro!

      render json: {
        status: :ok,
        code: 200,
        message: 'intro_completed'
      }
    else
      render json: {
        status: :ok,
        code: 3000,
        message: 'intro_already_completed',
        errors: 'This section has already been completed.'
      }
    end
  end
  
end