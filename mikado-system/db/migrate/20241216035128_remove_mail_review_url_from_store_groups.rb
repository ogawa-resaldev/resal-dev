class RemoveMailReviewUrlFromStoreGroups < ActiveRecord::Migration[7.0]
  def up
    remove_column :store_groups, :mail_review_url
  end

  def down
    add_column :store_groups, :mail_review_url, :text, :limit => 10000, :after => :mail_credit_2, comment: "メールのレビューURL"
  end
end
