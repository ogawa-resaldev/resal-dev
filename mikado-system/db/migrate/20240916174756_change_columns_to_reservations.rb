class ChangeColumnsToReservations < ActiveRecord::Migration[7.0]
  def up
    change_column :reservations, :option, :text, :limit => 10000
    change_column :reservations, :ng, :text, :limit => 10000
    change_column :reservations, :note, :text, :limit => 10000
  end

  def down
    change_column :reservations, :option, :string
    change_column :reservations, :ng, :string
    change_column :reservations, :note, :string
  end
end
