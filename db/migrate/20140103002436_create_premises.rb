class CreatePremises < ActiveRecord::Migration
  def change
    create_table :premises, :id => false do |t|
      t.string :id
      t.string :name
      t.string :premise_type
      t.string :address

      t.timestamps
    end
  end
end
