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

  def show
    @inspection = Inspection.includes( :infractions ).find( params[:id] )
  end
end
