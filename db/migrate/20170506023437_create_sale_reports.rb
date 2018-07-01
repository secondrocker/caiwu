class CreateSaleReports < ActiveRecord::Migration[5.1]
  def change
    create_table :sale_reports do |t|
      t.integer :year
      t.integer :month
      t.text :data_yml
      t.timestamps
    end
  end
end
