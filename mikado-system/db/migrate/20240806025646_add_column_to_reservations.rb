class AddColumnToReservations < ActiveRecord::Migration[7.0]
  def up
    add_column :reservations, :whiteboard, :text, :limit => 10000, :after => :note, comment: "情報共有用のホワイトボード"
  end

  def down
    remove_column :reservations, :whiteboard
  end
end
