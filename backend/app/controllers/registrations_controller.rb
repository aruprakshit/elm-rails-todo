class RegistrationsController < ApplicationController
  skip_before_action :authenticate_request
  
  def create
    service = CreateUser(signup_params)

    if service.has_error?
      render json: { error: service.errors.body }, status: service.errors.code
    else
      render json: { auth_token: service.result }
    end
  end

  private

  def signup_params
    params.require(:signup).permit(:email, :password, :password_confirmation)
  end
end
