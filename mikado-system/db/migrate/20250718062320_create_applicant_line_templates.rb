class CreateApplicantLineTemplates < ActiveRecord::Migration[7.0]
  def change
    create_table :applicant_line_templates do |t|
      t.integer :store_group_id, :null => false, comment: '店舗グループID'
      t.string :line_template_name, :null => false, comment: 'LINEテンプレート名'
      t.text :line_template_body, :null => false, comment: 'LINEテンプレート内容'

      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
