class CreateTeams < ActiveRecord::Migration[5.1]
  def change
    create_table :teams do |t|
      t.integer :team_set_id
      t.integer :leader_id
      t.integer :level
      t.timestamps
    end
  end
end
