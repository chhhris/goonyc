class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception


  def http_basic_auth
    authenticate_or_request_with_http_basic do |user, password|
      user == 'bqvc' && password == 'bqvc'
    end
  end
end
