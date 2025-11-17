class ChangeSendMailAPIColumnToStoreGroups < ActiveRecord::Migration[7.0]
  def up
    rename_column :store_groups, :send_mail_api, :mail_api
    change_column_comment(:store_groups, :mail_api, 'メールAPI')
  end

  def down
    rename_column :store_groups, :mail_api, :send_mail_api
    change_column_comment(:store_groups, :mail_api, 'メール送信のAPI')
  end
end
