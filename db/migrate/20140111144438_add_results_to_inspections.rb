class AddResultsToInspections < ActiveRecord::Migration
  def change
  	# Add more details to inspections
  	add_column :inspections, :result,        :string	# eg, Pass, Conditional Pass, or Fail
  	add_column :inspections, :details,       :string	# eg, 1 Conditional Infraction, 2 Minor Infractions
  	add_column :inspections, :details_short, :string	# eg, 1C, 1M

  	# It's not a simple pass/fail, so let's remove that column
  	remove_column :inspections, :passed
  end
end
