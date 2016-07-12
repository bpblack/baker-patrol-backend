class ApplicationController < ActionController::API
  include Knock::Authenticable
  include Pundit
end
