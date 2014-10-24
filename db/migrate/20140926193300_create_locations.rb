class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.decimal :lat
      t.decimal :lng
    end

    add_column :premises, :location_id, :integer
  end
end
