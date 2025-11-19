class CreateApplicantMailTemplates < ActiveRecord::Migration[7.0]
  def change
    create_table :applicant_mail_templates do |t|
      t.integer :store_group_id, :null => false, comment: '店舗グループID'
      t.string :mail_template_name, :null => false, comment: 'メールテンプレート名'
      t.string :mail_template_subject, :null => false, comment: 'メールテンプレート主題'
      t.text :mail_template_body, :null => false, comment: 'メールテンプレート内容'

      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
