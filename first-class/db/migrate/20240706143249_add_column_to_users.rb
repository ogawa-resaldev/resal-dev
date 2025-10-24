class AddColumnToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :active_flag, :boolean, :null => false, :default => true, :after => :password_digest, comment: "アクティブフラグ"
  end
end
