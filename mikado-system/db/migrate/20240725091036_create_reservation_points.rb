class CreateReservationPoints < ActiveRecord::Migration[7.0]
  def change
    create_table :reservation_points do |t|
      t.integer :reservation_id, :null => false, comment: '予約ID'
      t.string :point_name, :null => false, comment: 'ポイント名'
      t.string :point_detail, :null => false, comment: 'ポイント詳細'
      t.decimal :point, precision: 5, scale: 1, :null => false, comment: 'ポイント'
      t.decimal :support_point, precision: 5, scale: 1, :null => false, comment: '応援ポイント'

      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
