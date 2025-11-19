class AddColumnToUserTherapistSettings3 < ActiveRecord::Migration[7.0]
  def up
    add_column :user_therapist_settings, :mikado_coin_balance, :integer, :null => false, :default => 0, :after => :therapist_back_ratio, comment: "帝コイン残高"
  end

  def down
    remove_column :user_therapist_settings, :mikado_coin_balance
  end
end
