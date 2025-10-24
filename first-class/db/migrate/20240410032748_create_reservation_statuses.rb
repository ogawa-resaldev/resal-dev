class CreateReservationStatuses < ActiveRecord::Migration[7.0]
  def change
    create_table :reservation_statuses do |t|
      t.string :status_name, :null => false, comment: '予約ステータス名'

      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
