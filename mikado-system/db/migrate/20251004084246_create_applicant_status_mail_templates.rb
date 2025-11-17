class CreateApplicantStatusMailTemplates < ActiveRecord::Migration[7.0]
  def change
    create_table :applicant_status_mail_templates do |t|
      t.integer :store_group_id, :null => false, comment: '店舗グループID'
      t.integer :applicant_status_id, :null => false, comment: '応募者ステータスID'
      t.integer :applicant_mail_template_id, comment: '応募者メールテンプレートID'
      t.boolean :default_flag, :default => false, comment: 'デフォルトフラグ'

      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
