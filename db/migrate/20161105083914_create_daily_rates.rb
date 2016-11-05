class CreateDailyRates < ActiveRecord::Migration[5.0]
  def change
    create_table :daily_rates do |t|
      t.date :date
      t.float :rate

      t.timestamps
    end

    add_index :daily_rates, :date
  end
end
