class Api::V1::Washers::RegistrationsController < Api::V1::Washers::AuthsController
  skip_before_action :authenticate_washer!

  # POST /api/v1/washers/registrations(.:format)
  def create
    @washer = Washer.new(washer_params.merge(password_confirmation: washer_params[:password]))

    @washer.skip_finalized_washer_attributes = true

    if @washer.save
      @washer.send_one_time_password_email!

      render json: {
        code: 201,
        status: 'ok',
        message: 'created',
        flash: "Please check your email #{@washer.email} for a One Time Password (OTP) to log in to your account."
      }
    else
      render json: {
        code: 3000,
        status: 'ok',
        message: 'invalid_data',
        errors: @washer.errors.full_messages.first
      }
    end
  end

  private
  def washer_params
    params.require(:washer).permit(%i[
      full_name
      email
      password
    ])
  end
end
