class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def render *args
    set_aggregate_data
    super
  end

private
  def set_aggregate_data
  	@premise_count = Premise.count
  	@inspection_count = Inspection.count
  end
end
