class AddColumnToUserTherapistSettings4 < ActiveRecord::Migration[7.0]
  def up
    add_column :user_therapist_settings, :auto_complete, :text, :limit => 10000, :after => :mikado_coin_balance, comment: "自動補完"
  end

  def down
    remove_column :user_therapist_settings, :auto_complete
  end
end
