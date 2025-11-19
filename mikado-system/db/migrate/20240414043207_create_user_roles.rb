class CreateUserRoles < ActiveRecord::Migration[7.0]
  def change
    create_table :user_roles do |t|
      t.string :role, :null => false, comment: '権限'
      t.string :name, :null => false, comment: '権限名'

      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
