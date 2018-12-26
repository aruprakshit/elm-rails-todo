class ProfilesController < ApplicationController
  before_action :set_profile, only: [:show, :update]

  # GET /profiles/1
  def show
    render json: @profile
  end

  # PATCH/PUT /profiles/1
  def update
    if @profile.update(profile_params)
      render json: @profile
    else
      render json: @profile.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_profile
      @profile = current_user
    end

    # Only allow a trusted parameter "white list" through.
    def profile_params
      params.require(:profile).permit(:username, :email, :avatar, :first_name, :last_name)
    end
end
