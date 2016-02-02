class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :last_scan_time

  def last_scan_time
    lastest_scan = Site.select(:last_checked).where(:active => true).order(last_checked: :desc).first
    lastest_scan.last_checked
  end


end
