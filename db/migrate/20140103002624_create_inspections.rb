class CreateInspections < ActiveRecord::Migration
  def change
    create_table :inspections, :id => false do |t|
      t.string :id
      t.string :premise_id
      t.date :date
      t.string :inspection_reason
      t.string :note
      t.boolean :passed

      t.timestamps
    end
  end
end
