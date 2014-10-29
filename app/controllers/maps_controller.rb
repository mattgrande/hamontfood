class MapsController < ApplicationController
  def index
    @points = Location.includes(:premises => :most_recent)
  end
end