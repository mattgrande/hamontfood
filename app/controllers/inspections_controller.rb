class InspectionsController < ApplicationController

  # GET /
  # GET /inspections
  # GET /inspections.json
  def index
    @inspections = Inspection
      .includes(:premise)
      .order(:date => :desc)
      .limit( 100 )

    if params[:type] == 'Failed'
      @inspections = @inspections.where("result <> 'Passed'")
    end
  end
end
