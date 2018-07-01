class AddLeaderType2Teams < ActiveRecord::Migration[5.1]
  def change
    add_column :teams,:leader_type,:integer
  end
end
