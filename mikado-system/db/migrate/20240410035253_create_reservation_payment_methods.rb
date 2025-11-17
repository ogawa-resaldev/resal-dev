class CreateReservationPaymentMethods < ActiveRecord::Migration[7.0]
  def change
    create_table :reservation_payment_methods do |t|
      t.string :payment_method, :null => false, comment: '決済方法'

      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
