class CreateTeamSets < ActiveRecord::Migration[5.1]
  def change
    create_table :team_sets do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.timestamps
    end
    add_index :team_sets,:start_time
    add_index :team_sets,:end_time
  end
end
