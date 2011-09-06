class ApplicationController < ActionController::Base
  protect_from_forgery

  def not_found
    render :file => "public/404.html", :status => 404, :layout => false
  end
end
