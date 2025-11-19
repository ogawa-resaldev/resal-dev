class CreateReservationFees < ActiveRecord::Migration[7.0]
  def change
    create_table :reservation_fees do |t|
      t.integer :reservation_id, :null => false, comment: '予約ID'
      t.string :fee_type, :null => false, comment: '費用種別'
      t.string :fee_detail, :null => false, comment: '費用詳細'
      t.integer :amount, :null => false, comment: '金額(円)'
      t.integer :back_therapist_amount, :null => false, comment: 'セラピストバック金額(円)'

      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
