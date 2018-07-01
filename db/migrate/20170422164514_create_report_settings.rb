class CreateReportSettings < ActiveRecord::Migration[5.1]
  def change
    create_table :report_settings do |t|
      t.integer :year
      t.integer :month
      t.text :yml_data

      t.timestamps
    end
  end
end
