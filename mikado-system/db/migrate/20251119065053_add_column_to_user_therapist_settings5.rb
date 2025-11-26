class AddColumnToUserTherapistSettings5 < ActiveRecord::Migration[7.0]
  def up
    add_column :user_therapist_settings, :integrate_google_calendar_flag, :boolean, :null => false, :default => false, :after => :account_information, comment: "googleカレンダー連携フラグ"
    add_column :user_therapist_settings, :google_calendar_sync_token, :string, :after => :integrate_google_calendar_flag, comment: "googleカレンダーのsyncToken"
  end

  def down
    remove_column :user_therapist_settings, :integrate_google_calendar_flag
    remove_column :user_therapist_settings, :google_calendar_sync_token
  end
end
