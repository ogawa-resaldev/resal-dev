class ChangeDatatypeAccountInformationOfUserTherapistSettings < ActiveRecord::Migration[7.0]
  def up
    change_column :user_therapist_settings, :account_information, :text, :limit => 10000
  end

  def down
    change_column :user_therapist_settings, :account_information, :string
  end
end
