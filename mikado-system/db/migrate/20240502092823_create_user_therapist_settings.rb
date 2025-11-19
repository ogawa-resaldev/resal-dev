class CreateUserTherapistSettings < ActiveRecord::Migration[7.0]
  def change
    create_table :user_therapist_settings do |t|
      t.integer :user_id, :null => false, comment: 'ユーザーID'
      t.integer :therapist_back_ratio, :null => false, comment: 'セラピストバック率'
      t.string :notification_group_id, :null => false, comment: '通知グループID'

      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
