# TODO: implement authorization
class UsersController < ApplicationController
  def create
      user = User.create(
          name: params[:name],
          email: params[:email],
          password: params[:password]
      )
      if user.valid?
          render_user(user)
      else
          render json: { errors: user.errors.messages }, status: :bad_request
      end
  end

  def show
      user = User.find_by(id: params[:id])
      return not_found unless user.present?
      render_user(user)
  end

  def destroy
      user = User.find_by(id: params[:id])
      return not_found unless user.present?
      user.destroy
  end

  private

  def render_user(user)
      render json: user, except: [:password_digest]
  end
end
