class CreateReservationCostDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :reservation_cost_details do |t|
      t.integer :reservation_cost_id, :null => false, comment: '予約費用ID'
      t.string :cost_detail, :null => false, comment: '費用種別詳細'
      t.integer :amount, :null => false, comment: '金額(円)'
      t.integer :back_therapist_amount, :null => false, comment: 'セラピストバック金額(円)'

      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
