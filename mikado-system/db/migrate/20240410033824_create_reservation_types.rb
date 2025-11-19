class CreateReservationTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :reservation_types do |t|
      t.string :type_name, :null => false, comment: '予約タイプ'

      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
