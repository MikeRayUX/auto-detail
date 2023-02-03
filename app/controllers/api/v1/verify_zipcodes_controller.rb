class Api::V1::VerifyZipcodesController < Api::V1::Washers::AuthsController
  skip_before_action :authenticate_washer!
  before_action :set_default_format
  before_action :validate_form!

  def show
    @zip = params[:zipcode]

    if CoverageArea.find_by(zipcode: @zip).present?
      render json: {
        code: 200,
        data: {
          message: 'available',
          zipcode: @zip
        },
        status: :ok
      }
    else
      render json: {
        code: 3000,
        data: {
          message: 'not_available',
          zipcode: @zip
        },
        status: :ok
      }
    end
  end

  private

  def validate_form!
    @zip = params[:zipcode]
    unless @zip.present? && @zip.length == 5
      render json: {
        code: 5000,
        data: {
          message: 'bad_zipcode',
          errors: ['Invalid Zipcode Parameters']
        },
        status: :unauthorized
      }
    end
  end

end