class CreateSales < ActiveRecord::Migration[5.1]
  def change
    create_table :sales do |t|
      t.string :name
      t.integer :level
      t.integer :leader_type
      t.string  :alias_name
      t.timestamps
    end
  end
end
