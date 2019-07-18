class UsersController < ApplicationController

  before_action :authenticate_user!, except: [:create]

  # POST /users
  #
  # Request body:
  #   - name: string
  #   - email: string
  #   - password: string
  def create
    begin
      user = User.create(
        name: params[:name],
        email: params[:email],
        password: params[:password]
      )
    rescue ActiveRecord::RecordNotUnique => e
      errors = { email: [ "email is already taken" ] }
      return render json: { errors: errors }, status: :bad_request
    end
    if user.valid?
      render json: user
    else
      render json: { errors: user.errors.messages }, status: :bad_request
    end
  end

  # GET /users/:id
  def show
    user = User.find_by(id: params[:id])
    return not_found unless user.present?
    return forbidden unless user == current_user
    render json: user
  end

  # DELETE /users:id
  def destroy
    user = User.find_by(id: params[:id])
    return not_found unless user.present?
    return forbidden unless user == current_user
    user.destroy
  end
end
