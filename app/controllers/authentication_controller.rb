class AuthenticationController < ApplicationController
  def login
    Rails.logger.info " >>>>>>> In login"
    user = User.find_by(email: params[:email])
    Rails.logger.info " >>>>>>> user #{user.inspect}"
    if user&.authenticate(params[:password])
      token = JsonWebToken.encode(user_id: user.id)
      render json: { token: token }, status: :ok
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end
end
