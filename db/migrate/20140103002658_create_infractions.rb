class CreateInfractions < ActiveRecord::Migration
  def change
    create_table :infractions do |t|
      t.string :inspection_id
      t.string :infraction_type
      t.string :text

      t.timestamps
    end
  end
end
