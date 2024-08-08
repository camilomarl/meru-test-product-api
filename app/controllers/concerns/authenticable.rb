module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_request, unless: :authentication_controller?
  end

  private

  def authenticate_request
    Rails.logger.info ">>>>>>> In authenticate request"
    header = request.headers['Authorization']
    if header.blank?
      render json: { errors: 'Unauthorized' }, status: :unauthorized
    else
      token = header.split(' ').last
      decoded = JsonWebToken.decode(token)
      @current_user = User.find(decoded[:user_id]) if decoded
      render json: { errors: 'Unauthorized' }, status: :unauthorized unless @current_user
    end
  rescue ActiveRecord::RecordNotFound, JWT::DecodeError
    render json: { errors: 'Unauthorized' }, status: :unauthorized
  end

  def authentication_controller?
    self.class == AuthenticationController
  end
end