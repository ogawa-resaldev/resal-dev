class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.integer :user_role_id, :null => false, comment: 'ユーザー権限ID'
      t.string :name, :null => false, comment: 'ユーザー名'
      t.string :login_id, :null => false, comment: 'ログインID'
      t.string :password_digest, :null => false, comment: 'パスワード'

      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
