class CreateApplicantFees < ActiveRecord::Migration[7.0]
  def change
    create_table :applicant_fees do |t|
      t.integer :applicant_id, :null => false, comment: '応募者ID'
      t.string :fee_name, :null => false, comment: '費用名'
      t.integer :amount, :null => false, comment: '料金'
      t.string :annotation, comment: '注釈'
      t.date :receive_date, comment: '受取日'

      t.datetime :deleted_at, default: nil
      t.timestamps
    end
  end
end
