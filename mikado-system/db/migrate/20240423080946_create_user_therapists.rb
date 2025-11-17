class CreateUserTherapists < ActiveRecord::Migration[7.0]
  def change
    create_table :user_therapists do |t|
      t.integer :user_id, :null => false, comment: 'ユーザーID'
      t.integer :store_id, :null => false, comment: '店舗ID'
      t.integer :therapist_id, comment: 'セラピストID'

      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
