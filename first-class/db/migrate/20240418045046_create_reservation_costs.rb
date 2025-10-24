class CreateReservationCosts < ActiveRecord::Migration[7.0]
  def change
    create_table :reservation_costs do |t|
      t.string :cost_type, :null => false, comment: '予約費用種別'

      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
