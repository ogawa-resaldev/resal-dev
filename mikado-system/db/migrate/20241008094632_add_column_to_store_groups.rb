class AddColumnToStoreGroups < ActiveRecord::Migration[7.0]
  def up
    add_column :store_groups, :credit_fee_percentage, :integer, :null => false, :default => 0, :after => :name, comment: "クレジット手数料のパーセンテージ"
    add_column :store_groups, :send_mail_api, :text, :limit => 10000, :after => :credit_fee_percentage, comment: "メール送信のAPI"
    add_column :store_groups, :mail_name, :string, :after => :send_mail_api, comment: "メールの表記名"
    add_column :store_groups, :mail_signature, :text, :limit => 10000, :after => :mail_name, comment: "メールの署名"
    add_column :store_groups, :mail_transfer_bank, :text, :limit => 10000, :after => :mail_signature, comment: "メールの銀行振込先"
    add_column :store_groups, :mail_credit_1, :text, :limit => 10000, :after => :mail_transfer_bank, comment: "メールのクレジット情報1"
    add_column :store_groups, :mail_credit_2, :text, :limit => 10000, :after => :mail_credit_1, comment: "メールのクレジット情報2"
    add_column :store_groups, :mail_review_url, :text, :limit => 10000, :after => :mail_credit_2, comment: "メールのレビューURL"
    add_column :store_groups, :line_client_id, :string, :after => :mail_review_url, comment: "LINEのクライアントID"
    add_column :store_groups, :line_client_secret, :string, :after => :line_client_id, comment: "LINEのクライアントSECRET"
    add_column :store_groups, :line_default_target_id, :string, :after => :line_client_secret, comment: "LINEのデフォルトの送信ID"
    remove_column :store_groups, :dot_env_key
  end

  def down
    remove_column :store_groups, :credit_fee_percentage
    remove_column :store_groups, :send_mail_api
    remove_column :store_groups, :mail_name
    remove_column :store_groups, :mail_signature
    remove_column :store_groups, :mail_transfer_bank
    remove_column :store_groups, :mail_credit_1
    remove_column :store_groups, :mail_credit_2
    remove_column :store_groups, :mail_review_url
    remove_column :store_groups, :line_client_id
    remove_column :store_groups, :line_client_secret
    remove_column :store_groups, :line_default_target_id
    add_column :store_groups, :dot_env_key, :string, :after => :name, comment: "グループごとにDOTENVで使用するキー。大文字で登録する想定。"
  end
end
