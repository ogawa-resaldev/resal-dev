class AddColumnToUserTherapistSettings2 < ActiveRecord::Migration[7.0]
  def change
    add_column :user_therapist_settings, :mail_address, :string, :after => :therapist_back_ratio, comment: "メールアドレス"
    add_column :user_therapist_settings, :account_information, :string, :after => :mail_address, comment: "口座情報"
  end
end
