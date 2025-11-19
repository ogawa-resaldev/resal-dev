class AddColumnToReservation < ActiveRecord::Migration[7.0]
  def change
    add_column :reservations, :discount, :string, :after => :ng, comment: "割引"
  end
end
