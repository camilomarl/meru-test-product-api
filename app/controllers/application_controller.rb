class ApplicationController < ActionController::API
  include Authenticable
  include Pagy::Backend
end
