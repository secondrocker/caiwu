class CreateTeamSales < ActiveRecord::Migration[5.1]
  def change
    create_table :team_sales do |t|
      t.integer :team_id
      t.integer :sale_id
      t.timestamps
    end
  end
end
