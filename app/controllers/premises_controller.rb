class PremisesController < ApplicationController
  before_action :set_premise, only: [:show, :edit, :update, :destroy]

  # GET /premises
  # GET /premises.json
  def index
    @types    = Premise.get_types
    @premises = Premise.search( params[:type], params[:restaurant_name], params[:page] )
  end

  # GET /premises/1
  # GET /premises/1.json
  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_premise
      @premise = Premise.find(params[:id])
      @inspections = Inspection.where(:premise_id => params[:id]).order(:date => :desc)
      if params[:inspection_id].nil?
        @inspection = @inspections[0]
      else
        @inspection = @inspections.find { |i| i.id == params[:inspection_id] }
      end
    end
end
